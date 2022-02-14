"""This file is main file."""
import time
import argparse
from src.setup_logger import logger
from src import PostflightCheck


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='PrimeHub postflight check.')
    parser.add_argument('--primehub_cluster', type=str)
    parser.add_argument('--gpu', action='store_true')
    parser.add_argument('--app', action='store_true')
    args = parser.parse_args()

    now_time = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.localtime(time.time()))
    logger.info("=================")
    logger.info(
        "[ Info ] Start post-flight check testing, time: {}.".format(now_time))
    logger.info("[ Info ] PrimeHub app postflight check: {}.".format(args.app))
    logger.info("[ Info ] GPU device postflight check: {}.".format(args.gpu))
    logger.info("=================")
    postflight_check = PostflightCheck()
    postflight_check.initial_primehub_sdk(args.primehub_cluster)
    admin_error = postflight_check.admin_function_test()
    user_error = postflight_check.user_function_test(args.app, args.gpu)
    postflight_check.log_information_report(admin_error, user_error)
