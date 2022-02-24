import os
from pathlib import Path
from src.setup_logger import logger


class AdminFunctionTesting:
    def __init__(self, ph):
        self.ph = ph
        self.error = []

    def testing_function_list(self):
        logger.info("[ Portal ] Admin Function Testing:")
        self.group_testing()
        self.instance_type_testing()
        self.image_testing()
        self.secret_testing()
        self.volume_testing()
        return self.error

    def group_testing(self):
        logger.info("[ Test ] Number of group is larger than 0.")
        group_list = self.ph.groups.list()
        logger.debug(group_list)
        try:
            assert len(group_list) > 0, "Error"
            logger.success("[ OK ] Number of group is larger than 0.")
        except AssertionError:
            self.testing_error("[ Error ] Did not Build up any group.")

    def instance_type_testing(self):
        logger.info("[ Test ] Check instance type information.")
        basic_instance_type = ["cpu-1", "cpu-2", "gpu-1", "gpu-2"]
        for basic_type in basic_instance_type:
            logger.info("Check the instance type: {}.".format(basic_type))
            try:
                basic_type_instancetypes_information = self.ph.instancetypes.get(
                    basic_type)
                logger.debug(basic_type_instancetypes_information)
                logger.success("[ OK ] Check instance type information.")
            except Exception:
                self.testing_error(
                    "[ Error ] the default instance type is not contain {}.".format(basic_instance_type))

        logger.info("[ Test ] Number of instance type is correct.")
        try:
            instancetype_list = self.ph.instancetypes.list()
            logger.debug(instancetype_list)
            assert len(instancetype_list) == 4, "Error"
            logger.success("[ OK ] Number of instance type is correct.")
        except Exception:
            self.testing_error("[ Error ] Not the correct number of instancetype. The current number of instance type is {}.".format(
                len(instancetype_list)))

    def image_testing(self):
        basic_image_list = ["base-notebook", "pytorch-1", "tf-1", "tf-2"]
        logger.info("[ Test ] Check images information, Number of process: {}".format(
            len(basic_image_list)))
        correct_number = 0
        for basic_type in basic_image_list:
            logger.info("[ Test ] Check the image: {}.".format(basic_type))
            try:
                basic_image_information = self.ph.images.get(basic_type)
                logger.debug(basic_image_information)
                correct_number += 1
                logger.success("[ OK ] Progress: {}/{}, Check the image: {}. ".format(
                    correct_number, len(basic_image_list), basic_type))
            except Exception:
                self.testing_error(
                    "[ Error ] the default image is not contain {}.".format(basic_type))

        if correct_number != len(basic_image_list):
            self.testing_error("[ Error ] Check images information.")
        else:
            logger.success("[ OK ] Check images information")

        logger.info("[ Test ] Number of instance type is correct.")
        image_list = self.ph.images.list()
        logger.debug(image_list)
        try:
            assert len(image_list) == 4, "Error"
            logger.success("[ OK ] Number of instance type is correct.")
        except AssertionError:
            self.testing_error(
                "[ Error ] Not the correct number of images. The current number of instance type is {}.".format(len(image_list)))

    def secret_testing(self):
        logger.info("[ Test ] We can get the secret information")
        try:
            secrets = list(self.ph.secrets.list())
            logger.debug(secrets)
            logger.success("[ OK ] We can get the secret information")
            assert len(secrets) == 0
        except AssertionError:
            self.testing_error(
                "[ Error ] We cannot get the secrets information.")

    def volume_testing(self):
        logger.info("[ Test ] We can get the volume information.")
        try:
            volumes = list(self.ph.volumes.list())
            logger.debug(volumes)
            logger.success("[ OK ] We can get the volume information.")
            assert len(volumes) == 0
        except AssertionError:
            self.testing_error(
                "[ Error ] We cannot get the volumes information.")

    def testing_error(self, error_info):
        self.error.append("{}\n".format(error_info))
        logger.error(error_info)
