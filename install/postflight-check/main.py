"""This file is main file."""
import time
import argparse
from src.setup_logger import logger
from src import PostflightCheck


if __name__ == '__main__':
    # Optional tag.
    parser = argparse.ArgumentParser(description='PrimeHub postflight check.')
    # 1. PrimeHub APP testing
    # If you want to test PrimeHub APP, then please enable the share file on group setting in admin protal.
    parser.add_argument('--app', action='store_true')
    # 2. PrimeHub SDK group setting
    # If you want to change other group to do the PrimeHub postflight check, then you can add this tag to change it.
    parser.add_argument('--sdk_group', type=str, default=None)
    # 3. PrimeHub Community Version postflight check.
    parser.add_argument('--primehub_ce', action='store_true')
    args = parser.parse_args()

    # Part I: Asking question.
    input_json = {}
    logger.info("Please answer the following question:")
    # 1. PrimeHub cluster URL information
    input_json['primehub_cluster_url'] = input("primehub cluster URL: ")
    # 2. GPU device
    input_json['gpu_device_bool'] = (
        input("Does the cluster node contain GPU device? (y/n) ") == "y")
    # 3. Grafana Dashboard
    input_json['grafana_bool'] = (
        input("Does the cluster install Grafana Dashboard? (y/n) ") == "y")

    # Part II: Show Information
    start_time = time.strftime(
        '%Y-%m-%dT%H:%M:%SZ', time.localtime(time.time()))
    logger.info("=================")
    logger.info(
        "[ Info ] Start post-flight check testing, time: {}.".format(start_time))
    logger.info("[ Info ] PrimeHub app postflight check: {}.".format(args.app))
    logger.info(
        "[ Info ] GPU device postflight check: {}.".format(input_json['gpu_device_bool']))
    logger.info("[ Info ] Grafana postflight check: {}.".format(
        input_json['grafana_bool']))
    logger.info("=================")

    # Part III: Postflight Check
    postflight_check = PostflightCheck()
    # 1. Initial PrimeHub SDK
    postflight_check.initial_primehub_sdk(
        input_json['primehub_cluster_url'], args.sdk_group)
    # 2. Admin Portal Postflight Check
    admin_error = postflight_check.admin_function_test(
        input_json['primehub_cluster_url'], input_json['grafana_bool'])
    # 3. User Portal Postflight Check
    user_error = postflight_check.user_function_test(
        args.app, args.primehub_ce, input_json['gpu_device_bool'])
    # 4. Conclusion the result
    postflight_check.log_information_report(
        admin_error, user_error, start_time)
