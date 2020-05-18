import re
import escapism
import string
from collections import Mapping
from functools import lru_cache
import os
import yaml


# memoize so we only load config once
#
# acknowledge:
# https://github.com/jupyterhub/zero-to-jupyterhub-k8s/blob/master/jupyterhub/files/hub/z2jh.py
@lru_cache()
def _load_primehub_config():
    """Load configuration from disk

    Memoized to only load once
    """
    cfg = {}
    path = f"/srv/primehub/values.yaml"
    if os.path.exists(path):
        print(f"Loading {path}")
        with open(path) as f:
            cfg = yaml.safe_load(f)
    else:
        print(f"No config at {path}")
    return cfg

def get_primehub_config(key, default=None):
    """
    Find a config item of a given name & return it

    Parses everything as YAML, so lists and dicts are available too

    get_config("a.b.c") returns config['a']['b']['c']
    """
    value = _load_primehub_config()
    # resolve path in yaml
    for level in key.split('.'):
        if not isinstance(value, dict):
            # a parent is a scalar or null,
            # can't resolve full path
            return default
        if level not in value:
            return default
        else:
            value = value[level]
    return value


def set_primehub_config_if_not_none(cparent, name, key):
    """
    Find a config item of a given name, set the corresponding Jupyter
    configuration item if not None
    """
    data = get_primehub_config(key)
    if data is not None:
        setattr(cparent, name, data)



def convert_cpu_values_to_float(value):
        if isinstance(value, str) and value.endswith("m"):
            return float(value.replace("m", "")) / 1000
        return float(value)


def convert_mem_resource_to_bytes(mem_request):
    if not mem_request:
        return 0

    # TODO: need to consider different units, e.g. Mi
    if isinstance(mem_request, str):
        if re.match(r'.*Gi?$', mem_request):
            mem_request = float(re.sub(r'Gi?$', '', mem_request)) * GiB()
        elif re.match(r'.*Mi?$', mem_request):
            mem_request = float(re.sub(r'Mi?$', '', mem_request)) * MiB()
        elif re.match(r'.*(K|k)i?$', mem_request):
            mem_request = float(re.sub(r'(K|k)i?$', '', mem_request)) * KiB()
        else:
            return float(mem_request)
    return int(mem_request)

def GiB():
    return (1024 ** 3)

def MiB():
    return (1024 ** 2)

def KiB():
    return 1024

def escape_to_dns_label(input):
    safe_chars = set(string.ascii_lowercase + string.digits)
    safe_string = escapism.escape(input, safe=safe_chars, escape_char='-').lower()
    return safe_string

def unescape_dns_label(input):
    output = escapism.unescape(input, escape_char='-')
    return output

def escape_to_primehub_label(input):
    return "escaped-" + escape_to_dns_label(input)

def unescape_primehub_label(input):
    return unescape_dns_label(input[8:])
