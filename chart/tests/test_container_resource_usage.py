import asyncio
import unittest
from unittest import mock

from kubernetes_asyncio.client.models import V1Container, V1ResourceRequirements, V1PodStatus
from kubespawner.objects import make_pod

from jupyterhub_profiles import PrimeHubSpawner
from primehub_utils import *

_TEST_GROUP = "test-group"


def pod(containers):
    p = make_pod(name='test',
                 image='image',
                 cmd=['jupyterhub-singleuser'],
                 port=8888,
                 image_pull_policy='IfNotPresent'
                 )
    p.metadata.labels['primehub.io/group'] = escape_to_primehub_label(_TEST_GROUP)
    p.spec.containers = containers
    p.status = V1PodStatus()
    p.status.phase = "Pending"
    return p


def none_resource_container():
    c = V1Container(name='container')
    c.resources = V1ResourceRequirements()
    return c


def resource_container(cpu, gpu, memory):
    c = V1Container(name='container')
    settings = {
        "cpu": str(cpu),
        "memory": str(memory),
        "nvidia.com/gpu": str(gpu)

    }
    c.resources = V1ResourceRequirements(limits=settings, requests=settings)
    return c


class Fake(object):
    pod_list = []

    @property
    def pods(self):
        return self

    def values(self):
        return self.pod_list


class TestContainerResourceUsage(unittest.TestCase):

    def setUp(self):
        async def create():
            return PrimeHubSpawner(_mock=True)

        self.spawner = asyncio.run(create())
        self.pods = Fake()
        self.spawner.reflectors['primehub_pods'] = self.pods

    def test_resource_none_resources_container(self):
        pods = [pod([none_resource_container()])]
        self.pods.pod_list = pods
        self.assertEqual({'cpu': 0, 'gpu': 0, 'memory': 0.0},
                         self.spawner.get_container_resource_usage(dict(name=_TEST_GROUP)))

    def test_resource_normal_container(self):
        pods = [pod([resource_container(1, 0, 1024 ** 3)])]
        self.pods.pod_list = pods
        self.assertEqual({'cpu': 1.0, 'gpu': 0, 'memory': 1.0},
                         self.spawner.get_container_resource_usage(dict(name=_TEST_GROUP)))

    def test_resource_with_literal(self):
        pods = [pod([none_resource_container(), resource_container('1000m', 1, '2G')])]
        self.pods.pod_list = pods
        self.assertEqual({'cpu': 1.0, 'gpu': 1, 'memory': 2.0},
                         self.spawner.get_container_resource_usage(dict(name=_TEST_GROUP)))
