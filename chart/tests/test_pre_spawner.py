import unittest
from unittest import mock
import copy
from tornado import gen
from tornado import testing

from jupyterhub_profiles import PrimeHubSpawner, OIDCAuthenticator
import jupyterhub


def mock_spawner():
    return PrimeHubSpawner(_mock=True)


class AuthStateBuilder(object):

    def __init__(self):
        import uuid
        self.data = dict(sub=uuid.uuid4().hex,
                         roles=[
                             "offline_access",
                             "uma_authorization",
                             "img:base-notebook",
                             "it:cpu-only"
        ], email_verified=True, preferred_username="tester")
        self.data['quota'] = dict(gpu=0)
        self.data['project-quota'] = dict(gpu=0)
        self.launch_context = dict(groups=[])
        self.data['groups'] = []

        self._datasets_builder = _DatasetsBuilder()
        self.add_group('everyone')
        self.add_group('phusers')

    def add_group(self, name, **kwargs):
        self.launch_context['groups'].append(dict(name=name, datasets=[], **kwargs))
        self.data['groups'].append("/%s" % name)

    def add_dataset_role(self, group_name, name, dataset_type, **kwargs):
        if "/%s" % group_name in self.data['groups']:
            self.data['roles'].append("ds:%s" % name)
        if 'git' == dataset_type:
            ds = self._datasets_builder.add_git(name, **kwargs).data[-1]
        if 'pv' == dataset_type:
            ds = self._datasets_builder.add_pv(name, **kwargs).data[-1]
        if 'hostPath' == dataset_type:
            ds = self._datasets_builder.add_hostpath(name, **kwargs).data[-1]
        if 'nfs' == dataset_type:
            ds = self._datasets_builder.add_nfs(name, **kwargs).data[-1]
        if 'env' == dataset_type:
            ds = self._datasets_builder.add_env(name, **kwargs).data[-1]

        ds = copy.deepcopy(ds)
        ds['name'] = ds['metadata']['name']
        ds['global'] = kwargs.get('dataset_global', False)
        ds['writable'] = kwargs.get('writable', False)
        del ds['metadata']
        for g in self.launch_context['groups']:
            if g['name'] == group_name:
                g['datasets'].append(ds)
        return self

    def add_image_role(self, name):
        self.data['roles'].append("img:%s" % name)
        return self

    def add_instance_type_role(self, name):
        self.data['roles'].append("it:%s" % name)
        return self

    @gen.coroutine
    def get_oauth_user(self):
        return self.data

    @gen.coroutine
    def get_launch_context(self):
        return self.launch_context

    def get_datasets(self):
        return self._datasets_builder.get_datasets()

    def get_auth_state(self):
        return dict(
            launch_context=self.get_launch_context(),
            oauth_user=self.get_oauth_user())


class _DatasetsBuilder(object):

    def __init__(self):
        self.data = []

    def _template(self, name, **kwargs):
        tpl = dict(metadata=dict(name=name, annotations=dict()),
                   spec=dict(description="", displayName=name, type="", url="", variables=dict(), volumeName=""))

        for k, v in kwargs.items():
            tpl['metadata']['annotations']["dataset.primehub.io/%s" % k] = v
        return tpl

    def add_git(self, name, **kwargs):
        tpl = self._template(name, **kwargs)
        tpl['metadata']['annotations']['primehub-gitsync'] = True
        tpl['spec']['type'] = 'git'
        self.data.append(tpl)
        return self

    def add_pv(self, name, **kwargs):
        tpl = self._template(name, **kwargs)
        tpl['spec']['type'] = 'pv'
        tpl['spec']['volumeName'] = kwargs['volumeName']
        self.data.append(tpl)
        return self

    def add_hostpath(self, name, **kwargs):
        tpl = self._template(name, **kwargs)
        tpl['spec']['type'] = 'hostPath'
        tpl['spec']['hostPath'] = {'path': kwargs['path']}
        self.data.append(tpl)
        return self

    def add_nfs(self, name, **kwargs):
        tpl = self._template(name, **kwargs)
        tpl['spec']['type'] = 'nfs'
        tpl['spec']['nfs'] = {'path': kwargs['path'], 'server': kwargs['server']}
        self.data.append(tpl)
        return self

    def add_env(self, name, **kwargs):
        tpl = self._template(name, **kwargs)
        tpl['spec']['type'] = 'env'

        del tpl['metadata']['annotations']
        for k, v in kwargs.items():
            tpl['spec']['variables']['%s' % k] = v
        self.data.append(tpl)
        return self

    def get_datasets(self):
        return self.data


class FakeAuthenticator(OIDCAuthenticator):

    def user_volume_capacity(self, auth_state):
        return None

    def get_custom_resources(self, namespace, plural):
        return self.datasets


class TestPreSpawner(testing.AsyncTestCase):

    def setUp(self):
        testing.AsyncTestCase.setUp(self)
        self.spawner = mock_spawner()

        # user select phusers group
        self.spawner.user_options['group'] = dict(name='phusers')

        self.builder = AuthStateBuilder()
        self.spawner.user.get_auth_state = mock.Mock()
        self.spawner.user.get_auth_state.return_value = self.builder.get_auth_state()

        self.authenticator = FakeAuthenticator()
        self.authenticator.datasets = self.builder.get_datasets()

    def get_ln_command(self):
        ln_command = self.spawner.singleuser_lifecycle_hooks['postStart']['exec']['command']
        ln_command = [x.strip() for x in ln_command[-1].split(';')]
        return ln_command

    @testing.gen_test
    async def test_group_share_volume_mount(self):
        self.builder.add_group('i_have_a_volume', enabledSharedVolume=True, sharedVolumeCapacity=100, launchGroupOnly=False)
        self.authenticator.attach_project_pvc = mock.Mock(return_value=None)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        self.assertIn("/project/i-have-a-volume", self.authenticator.chown_extra)

    @testing.gen_test
    async def test_spawan_without_global_dataset(self):
        del self.builder.launch_context['groups'][0]['datasets']
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        self.assertEqual([], self.spawner.volumes)

    @testing.gen_test
    async def test_git_mount_without_annotations(self):
        """
        gitSyncHostRoot :  None => /home/dataset/
        gitSyncRoot     :  None => /gitsync/
        mountRoot       :  None => /datasets/
        """
        # add dataset foo without annotations
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='git', name='foo')
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("/home/dataset/foo",
                         self.spawner.volumes[0]['hostPath']['path'])
        self.assertEqual(
            "/gitsync/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /gitsync/foo/foo /datasets/foo",
                      self.get_ln_command())
        self.assertNotIn("ln -sf /gitsync/foo/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_git_mount_with_annotations_and_not_ending_slash(self):
        """
        gitSyncHostRoot :  /home/dataset
        gitSyncRoot     :  /gitsync
        mountRoot       :  /datasets
        """

        annotations = dict(gitSyncHostRoot='/home/dataset',
                           gitSyncRoot='/gitsync', mountRoot='/datasets')
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='git', name='foo', **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("/home/dataset/foo",
                         self.spawner.volumes[0]['hostPath']['path'])
        self.assertEqual(
            "/gitsync/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /gitsync/foo/foo /datasets/foo",
                      self.get_ln_command())
        self.assertNotIn("ln -sf /gitsync/foo/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_pv_mount_without_annotations(self):
        """
        mountRoot       :  None => /datasets/
        homeSymlink     :  None => 'false'
        """

        # add dataset foo without annotations
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='pv', name='foo', **dict(volumeName='foo'))
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("dataset-foo", self.spawner.volumes[0]['name'])
        self.assertEqual(
            "dataset-foo", self.spawner.volumes[0]['persistentVolumeClaim']['claimName'])
        self.assertEqual(
            "/datasets/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /datasets .", self.get_ln_command())
        self.assertNotIn("ln -sf /datasets/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_pv_mount_with_annotations_enable_home_symlink_and_without_ending_slash(self):
        """
        mountRoot       :  /datasets
        homeSymlink     :  'true'
        """
        annotations = dict(mountRoot='/datasets',
                           homeSymlink='true', volumeName='foo')
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='pv', name='foo', **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("dataset-foo", self.spawner.volumes[0]['name'])
        self.assertEqual(
            "dataset-foo", self.spawner.volumes[0]['persistentVolumeClaim']['claimName'])
        self.assertEqual(
            "/datasets/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /datasets .", self.get_ln_command())
        self.assertIn("ln -sf /datasets/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_dataset_not_in_launch_context_groups_bind_and_not_global(self):
        """
        mountRoot       :  /datasets
        homeSymlink     :  'true'
        launchGroupOnly :  'false'
        """
        annotations = dict(mountRoot='/datasets',
                           launchGroupOnly='false',
                           homeSymlink='true', volumeName='foo')
        self.builder.add_dataset_role(group_name='others', name='ds_other', dataset_type='pv', writable=False, dataset_global=False, **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        # Shouldn't mount if dataset is not in users' group set and not global
        self.assertEqual(0, len(self.spawner.volumes))

    @testing.gen_test
    async def test_dataset_without_group_bind_but_global_and_launchGroupOnly(self):
        """
        mountRoot       :  /datasets
        homeSymlink     :  'true'
        launchGroupOnly :  'true'
        """
        annotations = dict(mountRoot='/datasets',
                           launchGroupOnly='true',
                           homeSymlink='true', volumeName='foo')
        self.builder.add_dataset_role(group_name='everyone', name='ds_global', dataset_type='pv', writable=False, dataset_global=True, **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        # Shouldn't mount if dataset is not in users' group set and not global
        self.assertEqual(1, len(self.spawner.volumes))
        self.assertEqual(True, self.spawner.volumes[0]['persistentVolumeClaim']['readOnly'])

    @testing.gen_test
    async def test_dataset_global_not_in_launch_group(self):
        """
        global=true
        writable=true

        mountRoot       :  /datasets
        homeSymlink     :  'true'
        launchGroupOnly :  'false'
        """
        annotations = dict(mountRoot='/datasets',
                           launchGroupOnly='false',
                           homeSymlink='true', volumeName='foo')
        self.builder.add_dataset_role(group_name='everyone', name='ds_global', dataset_type='pv', writable=True, dataset_global=True, **annotations)
        self.builder.add_dataset_role(group_name='everyone', name='ds_global_readonly', dataset_type='pv', writable=False, dataset_global=True, **annotations)
        # This one shouldn't mount.
        self.builder.add_dataset_role(group_name='other', name='other_ds', dataset_type='pv', writable=False, dataset_global=True, **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        self.assertEqual(2, len(self.spawner.volumes))

        # Writable
        self.assertEqual('dataset-ds_global', self.spawner.volumes[0]['name'])
        self.assertEqual(False, self.spawner.volumes[0]['persistentVolumeClaim']['readOnly'])

        # ReadOnly
        self.assertEqual('dataset-ds_global_readonly', self.spawner.volumes[1]['name'])
        self.assertEqual(True, self.spawner.volumes[1]['persistentVolumeClaim']['readOnly'])

    @testing.gen_test
    async def test_hostpath_mount_without_annotations(self):
        """
        mountRoot       :  None => /datasets/
        homeSymlink     :  None => 'false'
        """

        # add dataset foo without annotations
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='hostPath', name='foo', **dict(path='/tmp/foobar'))
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("dataset-foo", self.spawner.volumes[0]['name'])
        self.assertEqual(
            "/tmp/foobar", self.spawner.volumes[0]['hostPath']['path'])
        self.assertEqual(
            "/datasets/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /datasets .", self.get_ln_command())
        self.assertNotIn("ln -sf /datasets/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_hostpath_mount_with_annotations_enable_home_symlink(self):
        """
        mountRoot       :  None => /datasets/
        homeSymlink     :  None => 'true'
        """
        # add dataset foo with annotations
        annotations = dict(mountRoot='/datasets',
                           homeSymlink='true', path='/tmp/foobar')
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='hostPath', name='foo', **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("dataset-foo", self.spawner.volumes[0]['name'])
        self.assertEqual(
            "/tmp/foobar", self.spawner.volumes[0]['hostPath']['path'])
        self.assertEqual(
            "/datasets/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /datasets .", self.get_ln_command())
        self.assertIn("ln -sf /datasets/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_nfs_mount_without_annotations(self):
        """
        mountRoot       :  None => /datasets/
        homeSymlink     :  None => 'false'
        """

        # add dataset foo without annotations
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='nfs', name='foo', **dict(path='/', server='10.0.0.1'))
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("dataset-foo", self.spawner.volumes[0]['name'])
        self.assertEqual(
            "/", self.spawner.volumes[0]['nfs']['path'])
        self.assertEqual(
            "10.0.0.1", self.spawner.volumes[0]['nfs']['server'])
        self.assertEqual(
            "/datasets/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /datasets .", self.get_ln_command())
        self.assertNotIn("ln -sf /datasets/foo .", self.get_ln_command())

    @testing.gen_test
    async def test_nfs_mount_with_annotations_enable_home_symlink(self):
        """
        mountRoot       :  None => /datasets/
        homeSymlink     :  None => 'true'
        """

        # add dataset foo with annotations
        annotations = dict(mountRoot='/datasets',
                           homeSymlink='true', path='/', server='10.0.0.1')
        self.builder.add_dataset_role(
            group_name='phusers', dataset_type='nfs', name='foo', **annotations)
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)

        self.assertEqual("dataset-foo", self.spawner.volumes[0]['name'])
        self.assertEqual(
            "/", self.spawner.volumes[0]['nfs']['path'])
        self.assertEqual(
            "10.0.0.1", self.spawner.volumes[0]['nfs']['server'])
        self.assertEqual(
            "/datasets/foo", self.spawner.volume_mounts[0]['mountPath'])

        # check symbolic link
        self.assertIn("ln -sf /datasets .", self.get_ln_command())
        self.assertIn("ln -sf /datasets/foo .", self.get_ln_command())

    def test_mount_env_datasets_launch_group_only(self):
        options = dict(launchGroupOnly='true',
                       FOO='bar')
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        self.builder.add_dataset_role(
            group_name='fake_group', name='fake_project', dataset_type='env', dataset_global=False, writable=True, **options)
        global_datasets = self.authenticator.get_global_datasets(auth_state['launch_context']['groups'])
        datasets_in_launch_group = self.authenticator.get_datasets_in_launch_group(
            launch_group_name='fake_group', auth_state=auth_state)

        result = self.authenticator.mount_dataset(self.spawner, global_datasets, datasets_in_launch_group, 'fake_project', self.builder.get_datasets()[0])
        self.assertEqual(result, True)
        self.assertEqual(self.spawner.environment.get('FAKE_PROJECT_FOO'), 'bar')

    def test_mount_git_datasets_not_global_and_not_in_launch_group(self):
        annotations = dict(mountRoot='/datasets',
                           launchGroupOnly='true',
                           homeSymlink='true', volumeName='foo')
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        self.authenticator.symlinks = []
        self.authenticator.chown_extra = []
        self.builder.add_dataset_role(
            group_name='fake_group', name='fake_project', dataset_type='git', dataset_global=False, writable=True, **annotations)

        global_datasets = self.authenticator.get_global_datasets(auth_state['launch_context']['groups'])
        datasets_in_launch_group = self.authenticator.get_datasets_in_launch_group(
            launch_group_name='phusers', auth_state=auth_state)

        result = self.authenticator.mount_dataset(self.spawner, global_datasets, datasets_in_launch_group, 'fake_project', self.builder.get_datasets()[0])

        self.assertEqual(result, False)

    def test_mount_git_datasets_not_global_and_but_in_launch_group(self):
        annotations = dict(mountRoot='/datasets',
                           launchGroupOnly='true',
                           homeSymlink='true', volumeName='foo')
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        self.authenticator.symlinks = []
        self.authenticator.chown_extra = []
        self.builder.add_dataset_role(
            group_name='phusers', name='fake_project', dataset_type='git', dataset_global=False, writable=True, **annotations)

        global_datasets = self.authenticator.get_global_datasets(auth_state['launch_context']['groups'])
        datasets_in_launch_group = self.authenticator.get_datasets_in_launch_group(
            launch_group_name='phusers', auth_state=auth_state)

        result = self.authenticator.mount_dataset(self.spawner, global_datasets, datasets_in_launch_group, 'fake_project', self.builder.get_datasets()[0])

        self.assertEqual(result, True)

    def test_mount_datasets_is_global(self):
        annotations = dict(mountRoot='/datasets',
                           homeSymlink='true', volumeName='foo')
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        self.authenticator.symlinks = []
        self.authenticator.chown_extra = []
        self.builder.add_dataset_role(
            group_name='everyone', name='fake_global', dataset_type='git', dataset_global=True, writable=True, **annotations)

        global_datasets = self.authenticator.get_global_datasets(auth_state['launch_context']['groups'])
        datasets_in_launch_group = self.authenticator.get_datasets_in_launch_group(
            launch_group_name='read_only_group', auth_state=auth_state)

        result = self.authenticator.mount_dataset(self.spawner, global_datasets, datasets_in_launch_group, 'fake_global', self.builder.get_datasets()[0])

        self.assertEqual(result, True)

    def test_get_datasets_in_launch_group(self):
        self.builder.add_group('read_only_group')
        annotations = dict(mountRoot='/datasets',
                           homeSymlink='true', volumeName='foo')
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        self.builder.add_dataset_role(
            group_name='read_only_group', name='foo', dataset_type='pv', writable=True, **annotations)
        datasets_in_launch_group = self.authenticator.get_datasets_in_launch_group(
            launch_group_name='read_only_group', auth_state=auth_state)
        self.assertEqual(datasets_in_launch_group.get('foo').get('writable'), True)

    def test_get_datasets_in_launch_group_without_right_group(self):
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        annotations = dict(mountRoot='/datasets',
                           launchGroupOnly='false',
                           homeSymlink='true', volumeName='foo')
        self.builder.add_dataset_role(
            group_name='read_only_group', name='foo-test', dataset_type='pv', dataset_global=True, writable=True, **annotations)
        datasets_in_launch_group = self.authenticator.get_datasets_in_launch_group(
            launch_group_name='read_only_group', auth_state=auth_state)
        self.assertEqual({}, datasets_in_launch_group)


    def test_get_global_datasets(self):
        self.builder.add_group('read_only_group')
        annotations = dict(mountRoot='/datasets',
                           homeSymlink='true', volumeName='foo')
        self.builder.add_dataset_role(
            group_name='read_only_group', name='foo_global', dataset_type='pv', writable=True, dataset_global=True, **annotations)
        self.builder.add_dataset_role(
            group_name='read_only_group', name='foo_private', dataset_type='pv', writable=True, dataset_global=False, **annotations)
        auth_state = dict(
            launch_context=self.builder.launch_context,
            oauth_user=self.builder.data
        )
        self.assertNotEqual(self.authenticator.get_global_datasets(auth_state['launch_context']['groups']).get('foo_global', None), None)
        self.assertEqual(self.authenticator.get_global_datasets(auth_state['launch_context']['groups']).get('foo_private', None), None)

    @testing.gen_test
    async def test_safe_mode_feature(self):
        # verify default behavior: safe_mode=False
        self.spawner.volume_mounts.append({'mountPath': '/home/jovyan'})
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        self.assertEqual({'mountPath': '/home/jovyan'}, self.spawner.volume_mounts[0])

        self.spawner.enable_safe_mode = True
        await self.authenticator.pre_spawn_start(self.spawner.user, self.spawner)
        self.assertEqual({'mountPath': '/home/jovyan/user'}, self.spawner.volume_mounts[0])
