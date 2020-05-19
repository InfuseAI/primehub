# This is the entry point of jupyterhub configuration for primehub
files=[
    '/srv/primehub/metrics_route.py',
    '/srv/primehub/primehub_utils.py',
    '/srv/primehub/jupyterhub_profiles.py'
]

for file in files:
    exec(open(file).read())
