import time
import unittest

from primehub_utils import *


class TestPrimeHubUtils(unittest.TestCase):

    def test_convert_mem_resource_to_bytes(self):
        self.assertEqual(GiB(), convert_mem_resource_to_bytes('1G'))
        self.assertEqual(MiB() * 500, convert_mem_resource_to_bytes('500M'))
        self.assertEqual(MiB() * 512, convert_mem_resource_to_bytes('512Mi'))
        self.assertEqual(KiB() * 512, convert_mem_resource_to_bytes('512k'))
        self.assertEqual(KiB() * 512, convert_mem_resource_to_bytes('512Ki'))
