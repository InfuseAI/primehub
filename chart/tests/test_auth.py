import asyncio
import unittest
from unittest import mock

import pytest
from jupyterhub.handlers import BaseHandler, LoginHandler
from tornado import gen, httpclient, testing

from jupyterhub_profiles import OIDCAuthenticator, PrimeHubSpawner


class FakeAuthenticator(OIDCAuthenticator):

    def user_volume_capacity(self, auth_state):
        return None

    def get_custom_resources(self, namespace, plural):
        return self.datasets


class TestAuthentication(unittest.TestCase):

    def setUp(self) -> None:
        self.authenticator = FakeAuthenticator()

        async def test():
            spawner = PrimeHubSpawner(_mock=True)
            self.spawner = spawner

        asyncio.run(test())

        self.spawner.user.get_auth_state = mock.Mock()

        async def x():
            f = asyncio.Future()
            f.set_result(dict(
                oauth_user=dict(sub='fake_user_id'),
                access_token='fake_token'
            ))
            return f

        self.spawner.user.get_auth_state.return_value = x()
        self.authenticator = FakeAuthenticator()
        self.async_patcher = mock.patch('tornado.httpclient.AsyncHTTPClient')
        self.authenticator.client = self.async_patcher.start()

    async def get_access_token(self, result):
        return result

    async def fetch_context(self):
        return dict(user='fake_user', system='fake_system')

    async def get_response(self, code=200, result=""):
        request = httpclient.HTTPRequest('http://google.com')
        return httpclient.HTTPResponse(request, code)

    def test_verify_access_token_success(self):
        async def test():
            self.authenticator.client.fetch.side_effect = lambda url, method='GET', headers=dict(): \
                self.get_response(code=200)
            result = await self.authenticator.verify_access_token(self.spawner.user)
            self.assertEqual(result, True)

        asyncio.run(test())

    def test_verify_access_token_not_200(self):
        async def test():
            self.authenticator.client.fetch.side_effect = lambda url, method='GET', headers=dict(): self.get_response(
                code=401)

            result = await self.authenticator.verify_access_token(self.spawner.user);
            self.assertEqual(result, False)

        asyncio.run(test())

    def test_verify_access_token_raise_exception(self):
        async def test():
            self.authenticator.client.fetch.side_effect = lambda url, method='GET', headers=dict(): 1 / 0
            result = await self.authenticator.verify_access_token(self.spawner.user);
            self.assertEqual(result, False)

        asyncio.run(test())

    def test_refresh_user_skip_when_graphql_call(self):
        async def test():
            handler = mock.Mock(spec=LoginHandler)
            with self.assertLogs(level='DEBUG') as cm:
                result = await self.authenticator.refresh_user(self.spawner.user, handler)
                self.assertFalse(result)
                self.assertIn('skip refresh user in handler', cm.output[0])

        asyncio.run(test())

    def test_refresh_user_not_have_user_id(self):
        async def test():
            handler = mock.Mock(spec=BaseHandler)
            self.spawner.user.get_auth_state.return_value = self.get_access_token(dict(
                oauth_user=dict(),
                access_token='fake_token'
            ))
            with self.assertLogs(level='DEBUG') as cm:
                result = await self.authenticator.refresh_user(self.spawner.user, handler)
                self.assertFalse(result)
                self.assertIn('user id not found', cm.output[1])

        asyncio.run(test())

    @mock.patch('jupyterhub_profiles.fetch_context')
    def test_refresh_user_unchange(self, mock_fetch_context):
        async def test():
            mock_fetch_context.return_value = self.fetch_context()
            self.authenticator.client.fetch.side_effect = lambda url, method='GET', headers=dict(): self.get_response(
                code=200)
            handler = mock.Mock(spec=BaseHandler)
            self.spawner.user.get_auth_state.return_value = self.get_access_token(dict(
                oauth_user=dict(sub='fake_user'),
                access_token='fake_token',
                launch_context='fake_user',
                system='fake_system'
            ))
            result = self.authenticator.refresh_user(self.spawner.user, handler)
            self.assertTrue(result)

        asyncio.run(test())

    @mock.patch('jupyterhub_profiles.fetch_context')
    def test_refresh_user_changed(self, mock_fetch_context):
        async def test():
            mock_fetch_context.return_value = self.fetch_context()
            self.authenticator.client.fetch.side_effect = lambda url, method='GET', headers=dict(): self.get_response(
                code=200)
            handler = mock.Mock(spec=BaseHandler)
            self.spawner.user.get_auth_state.return_value = await self.get_access_token(dict(
                oauth_user=dict(sub='fake_user'),
                access_token='fake_token',
                launch_context='fake_user_old',
                system='fake_system_old'
            ))
            with self.assertLogs(level='DEBUG') as cm:
                result = await self.authenticator.refresh_user(self.spawner.user, handler)
                self.assertIn('is outdated, update state', cm.output[1])
                self.assertEqual(result, dict(
                    auth_state=dict(
                        access_token='fake_token',
                        launch_context='fake_user',
                        oauth_user=dict(sub='fake_user'),
                        system='fake_system'
                    )
                ))

        asyncio.run(test())
