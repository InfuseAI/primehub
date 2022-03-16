import os
import coloredlogs
import logging

os.environ["COLOREDLOGS_LOG_FORMAT"] = "%(asctime)s [%(levelname)s] %(message)s"
os.environ["COLOREDLOGS_LEVEL_STYLES"] = "success=green,debug=write,faint;warning=yellow;error=red;critical=cyan;result=8;"

SUCCESS = 25
logging.addLevelName(SUCCESS, 'SUCCESS')
RESULT = 15
logging.addLevelName(RESULT, 'RESULT')

def success(self, message, *args, **kws):
    self.log(SUCCESS, message, *args, **kws)

def result(self, message, *args, **kws):
    self.log(RESULT, message, *args, **kws)

logging.Logger.success = success
logging.Logger.result = result

logging.basicConfig()
logger = logging.getLogger(__name__)
logger.setLevel(SUCCESS)
logger.setLevel(RESULT)
# Higher than debug = 10 and lower than result = 15
coloredlogs.install(level=11, logger=logger)
