import os
import json
import requests
from pathlib import Path
from src.setup_logger import logger
from primehub import PrimeHubException


class AdminFunctionTesting:
    def __init__(self, ph):
        """Initial the class and variable."""
        self.ph = ph
        self.error = []

    def testing_function_list(self, primehub_cluster_url, grafana_bool):
        """testing_function_list:
        This is the main function to do the postflight check in admin portal.
        """
        logger.info("[ Portal ] Admin Function Testing:")
        self.group_testing()
        self.instance_type_testing()
        self.image_testing()
        self.secret_testing()
        self.volume_testing()
        if grafana_bool:
            self.grafana_testing(primehub_cluster_url)
        return self.error

    def group_testing(self):
        """group testing: Check the group is not None.
        """
        # Variable setting
        if os.getenv("basic_group_list") is None:
            basic_group_list = ["phusers"]
            logger.result("Get the default list.")
        else:
            basic_group_list = eval(os.getenv("basic_group_list"))
            logger.result("Get the environment list.")
        logger.info("Basic group list: {}".format(basic_group_list))

        # Get the list of PrimeHub group.
        logger.info("[ Test ] Number of group is correct.")
        group_list = None
        try:
            group_list = self.ph.groups.list()
            logger.success("[ OK ] Successfully get the list of group.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        # If we successfully get the group list from PrimeHub, then we check the number of group list.
        if group_list is not None:
            logger.result(group_list)
            try:
                assert len(group_list) == len(basic_group_list), "Error"
                logger.success("[ OK ] Number of group is correct.")
            except AssertionError:
                self.testing_error("[ Error ] Did not Build up any group.")

        # Check the information of the group list.
        logger.info("[ Test ] Check the information of group list, Number of process: {}".format(
            len(basic_group_list)))
        count_number = 0
        for basic_type in basic_group_list:
            count_number += 1
            logger.info(
                "[ Test ] Process: {}/{}, Check the group: {}".format(count_number, len(basic_group_list), basic_type))

            # Get the information of the group list.
            basic_type_group_information = None
            try:
                basic_type_group_information = self.ph.groups.get(
                    basic_type)
                logger.success(
                    "[ OK ] Successfully get the value of group.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

            # Check the information contains the value.
            self.check_sdk_name("group", basic_type,
                               basic_type_group_information)

    def instance_type_testing(self):
        """instance_type_testing: Check the instance type contains default setting.
        """
        # Variable setting
        if os.getenv("basic_instance_list") is None:
            basic_instance_list = ["cpu-1", "cpu-2", "gpu-1", "gpu-2"]
            logger.result("Get the default list.")
        else:
            basic_instance_list = eval(os.getenv("basic_instance_list"))
            logger.result("Get the environment list.")
        logger.info("Basic Instance type: {}".format(basic_instance_list))

        # Get the list of PrimeHub instance type.
        logger.info("[ Test ] Number of instance type is correct.")
        instancetype_list = None
        try:
            instancetype_list = self.ph.instancetypes.list()
            logger.success(
                "[ OK ] Successfully get the list of instance type.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        # Check: The number of instance type is correct.
        if instancetype_list is not None:
            logger.result(instancetype_list)
            try:
                assert len(instancetype_list) == len(
                    basic_instance_list), "ERROR"
                logger.success("[ OK ] Number of instance type is correct.")
            except AssertionError:
                self.testing_error(
                    "[ Error ] The number of instance type is not correct.")

        # Check the information of the instance type.
        logger.info("[ Test ] Check the information of instance type, Number of process: {}".format(
            len(basic_instance_list)))
        count_number = 0
        for basic_type in basic_instance_list:
            count_number += 1
            logger.info(
                "[ Test ] Process: {}/{}, Check the instance type: {}".format(count_number, len(basic_instance_list), basic_type))

            # Get the information of the instance type.
            basic_type_instancetype_information = None
            try:
                basic_type_instancetype_information = self.ph.instancetypes.get(
                    basic_type)
                logger.success(
                    "[ OK ] Successfully get the value of instance type.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

            # Check the information contains the value.
            self.check_sdk_name("instance type", basic_type,
                               basic_type_instancetype_information)

    def image_testing(self):
        """image_testing: Check the image contains default setting.
        """
        # Variable setting
        if os.getenv("basic_image_list") is None:
            basic_image_list = ["base-notebook", "pytorch-1", "tf-1", "tf-2"]
            logger.result("Get the default list.")
        else:
            basic_image_list = eval(os.getenv("basic_image_list"))
            logger.result("Get the environment list.")
        logger.info("Basic image list: {}".format(basic_image_list))

        # Check: Successfully get the image list
        logger.info("[ Test ] Get the image list")
        image_list = None
        try:
            image_list = self.ph.images.list()
            logger.success(
                "[ OK ] Successfully get the image list.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        # Check: the number of image list is correct.
        logger.info("[ Test ] Number of image list is correct.")
        if image_list is not None:
            logger.result(image_list)
            try:
                assert len(image_list) == len(basic_image_list), "ERROR"
                logger.success("[ OK ] The number of image list is correct.")
            except AssertionError:
                self.testing_error(
                    "[ Error ] Not the correct number of images.")

        # Check the information of the instance type.
        logger.info("[ Test ] Check images information, Number of process: {}".format(
            len(basic_image_list)))
        count_number = 0
        for basic_type in basic_image_list:
            count_number += 1
            logger.info("[ Test ] Process: {}/{}, Check the image: {}".format(
                count_number, len(basic_image_list), basic_type))

            # Get the information of the image.
            basic_type_image_information = None
            try:
                basic_type_image_information = self.ph.images.get(basic_type)
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

            # Check the image content.
            self.check_sdk_name("image", basic_type,
                               basic_type_image_information)

    def secret_testing(self):
        """secret_testing: Check the secret list contains default setting.
        """
        # Variable setting
        if os.getenv("basic_secret_list") is None:
            basic_secret_list = []
            logger.result("Get the default list.")
        else:
            basic_secret_list = eval(os.getenv("basic_secret_list"))
            logger.result("Get the environment list.")

        # Check: Successfully get the secret list.
        logger.info("[ Test ] We can get the secret information")
        secret_list = None
        try:
            secret_list = list(self.ph.secrets.list())
            logger.success(
                "[ OK ] Successfully get the secret list.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        if secret_list is not None:
            logger.result(secret_list)
            try:
                assert len(secret_list) == len(basic_secret_list), "ERROR"
                logger.success("[ OK ] The number of secret list is correct.")
            except AssertionError:
                self.testing_error(
                    "[ Error ] The number of secret list is not correct.")

    def volume_testing(self):
        """volume_testing: Check the volume list contains default setting.
        """
        # Variable setting
        if os.getenv("basic_volume_list") is None:
            basic_volume_list = []
            logger.result("Get the default list.")
        else:
            basic_volume_list = eval(os.getenv("basic_volume_list"))
            logger.result("Get the environment list.")

        # Check: Successfully get the volume list.
        logger.info("[ Test ] We can get the volume information")
        volume_list = None
        try:
            volume_list = list(self.ph.volumes.list())
            logger.success(
                "[ OK ] Successfully get the volume list.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        if volume_list is not None:
            logger.result(volume_list)
            try:
                assert len(volume_list) == len(basic_volume_list), "ERROR"
                logger.success("[ OK ] The number of volume list is correct.")
            except AssertionError:
                self.testing_error(
                    "[ Error ] The number of volume list is not correct.")

    def grafana_testing(self, primehub_cluster_url):
        """grafana_testing: Check the grafana health check status.
        """
        # Variable setting
        logger.info("[ Test ] Grafana health check API testing.")
        grafana_url = "{}/grafana/".format(primehub_cluster_url)
        health_check_api = "{}/api/health".format(grafana_url)
        response = requests.post(health_check_api)

        # Check the grafana health check status.
        try:
            response_json = json.loads(response.text)
            assert response_json["database"] == "ok", "ERROR"
        except AssertionError:
            self.testing_error(
                "[ Error ] Grafana API status code: {}".format(response.status_code))
        except Exception:
            self.testing_error(
                "[ Error ] We get the wrong grafana health check API information.")

    def check_sdk_name(self, test_type, basic_type, basic_type_information):
        """check_sdk_name: Check content name is correct.
        """
        # Check the image content.
        if basic_type_information is not None:
            logger.result(basic_type_information)
            try:
                assert basic_type_information['name'] == basic_type, "ERROR"
                logger.success(
                    "[ OK ] Check the {} information.".format(test_type))
            except AssertionError:
                self.testing_error(
                    "[ Error ] the information of the {} is not correct.".format(basic_type))
        else:
            self.testing_error(
                "[ Error ] the information of the {} is None.".format(basic_type))

    def testing_error(self, error_info):
        """testing_error: Store error and output error message.
        """
        self.error.append("{}\n".format(error_info))
        logger.error(error_info)
