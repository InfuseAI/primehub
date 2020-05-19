import json
from jupyterhub import handlers
from tornado.web import RequestHandler

class FixupMetricsHandler(RequestHandler):
    async def get(self, user_name):
        self.set_status(503)
        # Tornado will response json when give chuck as a dictionary.
        self.finish(dict(message="User %s is not running" % user_name))

handlers.default_handlers[:0] = [
    (r"/user/(?P<user_name>[^/]+)/api/.*", FixupMetricsHandler),
    (r"/user/(?P<user_name>[^/]+)/metrics", FixupMetricsHandler),
]
