import os
import time
from primehub import PrimeHub, PrimeHubConfig
from src.admin_function import AdminFunctionTesting
from src.user_function import UserFunctionTesting
from src.setup_logger import logger


class PostflightCheck:
    def __init__(self):
        self.ph = PrimeHub(PrimeHubConfig())

    def initial_primehub_sdk(self, primehub_cluster):
        if not os.path.exists("/root/.primehub/config.json"):
            self.ph.config.generate(primehub_cluster)
        self.ph = PrimeHub(PrimeHubConfig())
        logger.info("=================")

        if self.ph.is_ready():
            logger.info("[ Info ] PrimeHub Python SDK setup successfully")
            logger.debug("[ Info ] Current Group: {}".format(
                self.ph.primehub_config.current_group))
        else:
            logger.error(
                "[ Error ] PrimeHub Python SDK couldn't get the group information, please check the configuration.")

    def admin_function_test(self):
        admin_function_testing = AdminFunctionTesting(self.ph)
        admin_error = admin_function_testing.testing_function_list()
        return admin_error

    def user_function_test(self, app_test, gpu_test):
        user_function_testing = UserFunctionTesting(self.ph)
        user_error = user_function_testing.testing_function_list(
            app_test, gpu_test)
        return user_error

    def log_information_report(self, admin_error, user_error):
        now_time = time.strftime('%Y-%m-%dT%H:%M:%SZ',
                                 time.localtime(time.time()))
        logger.info("=================")
        logger.info("[ Final ] Testing report:")
        if len(admin_error) + len(user_error) == 0:
            logger.success("[ OK ] Done for PrimeHub postflight check.")
        else:
            logger.error("[ Error ] Please check the error postflight check:")
            if len(admin_error) > 0:
                logger.error("[ Portal ] Admin function error:")
                for error in admin_error:
                    logger.error(error)
            if len(user_error) > 0:
                logger.error("[ Portal ] User function error:")
                for error in user_error:
                    logger.error(error)
        logger.info("=================")
        logger.info(
            "Finish post-flight check testing, time: {}".format(now_time))
