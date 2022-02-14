import os
import coloredlogs
import logging

os.environ["COLOREDLOGS_LOG_FORMAT"] = "%(asctime)s [%(levelname)s] %(message)s"
os.environ["COLOREDLOGS_LEVEL_STYLES"] = "success=green,debug=write,faint;warning=yellow;error=red;critical=cyan"

SUCCESS = 15
logging.addLevelName(SUCCESS, 'SUCCESS')


def success(self, message, *args, **kws):
    self.log(SUCCESS, message, *args, **kws)


logging.Logger.success = success

logging.basicConfig()
logger = logging.getLogger(__name__)
logger.setLevel(SUCCESS)
coloredlogs.install(level='DEBUG', logger=logger)
