import time
import unittest

from jupyterhub_profiles import OAuthStateStore
from primehub_utils import *


class TestPrimeHubUtils(unittest.TestCase):

    def test_convert_mem_resource_to_bytes(self):
        self.assertEqual(GiB(), convert_mem_resource_to_bytes('1G'))
        self.assertEqual(MiB() * 500, convert_mem_resource_to_bytes('500M'))
        self.assertEqual(MiB() * 512, convert_mem_resource_to_bytes('512Mi'))
        self.assertEqual(KiB() * 512, convert_mem_resource_to_bytes('512k'))
        self.assertEqual(KiB() * 512, convert_mem_resource_to_bytes('512Ki'))


class TestOAuthStateStore(unittest.TestCase):

    def test_oauth_state_store(self):
        store = OAuthStateStore()
        store.add_state('u1', 's1')

        self.assertTrue(store.validate('u1', 's1'))
        time.sleep(OAuthStateStore.PURGE_INTERVAL / 2)
        self.assertTrue(store.validate('u1', 's1'))

        time.sleep(OAuthStateStore.PURGE_INTERVAL)
        self.assertFalse(store.validate('u1', 's1'))
