import os
import uuid
from src.setup_logger import logger
from primehub import PrimeHubException


class UserFunctionTesting:
    def __init__(self, ph):
        self.ph = ph
        self.error = []

    def testing_function_list(self, app_test, primehub_ce_bool, gpu_test):
        logger.info("[ Portal ] User Function Testing:")
        if primehub_ce_bool is False:
            self.jobs_testing()
        self.datasets_testing()
        if gpu_test:
            self.gpu_testing()
        if app_test:
            self.apps_testing()
        return self.error

    def jobs_testing(self):
        """jobs_testing: Test the job is workable.
        """
        # Initial variables
        config = {
            "instanceType": "cpu-1",
            "image": "base-notebook",
            "displayName": "short-job",
            "command": "echo \"test1\"\necho \"test2\"",
        }

        # Submit a job
        logger.info("[ Status ] Submit the job and get the log.")
        logger.info("[ Test ] Submit the job.")
        test_job = None
        try:
            test_job = self.ph.jobs.submit(config)
            logger.success("[ OK ] Submit the job.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        # Wait the job to be done
        if test_job is not None:
            logger.result(test_job)

            logger.info('[ Test ] Wait for the job finishing.')
            wait_info = None
            try:
                wait_info = self.ph.jobs.wait(test_job['id'])
                logger.success("[ OK ] The PrimeHub job is finishing.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

            if wait_info is not None:
                logger.result(wait_info)

                # Get PrimeHub job logs
                logger.info('[ Test ] Get the job log.')
                try:
                    logs = self.ph.jobs.logs(test_job['id'])
                    log_content = list(logs)[0].decode("utf-8")
                    logger.result(log_content)
                    logger.success("[ OK ] Successfully get the job log.")
                except AssertionError:
                    self.testing_error("[ Error ] We cannot get the job log.")
                except PrimeHubException as e:
                    self.testing_error(
                        "[ Error ] PrimeHub SDK error: {}".format(e))

                correct_message = ["test1", "test2",
                                   "Artifacts: no artifact found"]
                logger.info('[ Status ] Check the job log information.')
                try:
                    for message in correct_message:
                        assert message in log_content, "Error"
                    logger.success("[ OK ] The log information is correct.")
                except Exception:
                    self.testing_error("[ Error ] We get the wrong job log.")

    def gpu_testing(self):
        """gpu_testing: Test GPU device can be used in PrimeHub.
        """
        config = {
            "instanceType": "gpu-1",
            "image": "base-notebook",
            "displayName": "short-job",
            "command": "nvidia-smi",
        }
        logger.info(
            "[ Status ] Submit the job and get the correct nvidia-smi log.")

        # Submit a job
        logger.info("[ Test ] Submit the job.")
        test_job = None
        try:
            test_job = self.ph.jobs.submit(config)
            logger.success("[ OK ] Submit the job.")
        except PrimeHubException as e:
            self.testing_error("[ Error ] PrimeHub SDK error: {}".format(e))

        # Wait the job to be done
        if test_job is not None:
            logger.result(test_job)

            logger.info('[ Test ] Wait for the job finishing.')
            wait_info = None
            try:
                wait_info = self.ph.jobs.wait(test_job['id'])
                logger.success("[ OK ] The PrimeHub job is finishing.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

            if wait_info is not None:
                logger.result(wait_info)

                # Get PrimeHub job logs
                logger.info('[ Test ] Get the job log.')
                try:
                    logs = self.ph.jobs.logs(test_job['id'])
                    log_content = ''.join(list(logs)).decode("utf-8")
                    logger.result(log_content)
                    logger.success("[ OK ] Successfully get the job log.")
                except PrimeHubException as e:
                    self.testing_error(
                        "[ Error ] PrimeHub SDK error: {}".format(e))

                logger.info(
                    '[ Test ] Check the job log contains nvidia-smi information.')
                try:
                    assert "NVIDIA-SMI" in log_content, "ERROR"
                    logger.success(
                        '[ Ok ] Successfully get the nvidia-smi log information.')
                except AssertionError:
                    self.testing_error("[ Error ] We get the wrong job log.")

    def apps_testing(self):
        """apps_testing: Check the PrimeHub app can be used.
        """
        # create an application
        random_id = uuid.uuid4().hex[:5]

        config = {
            "templateId": "mlflow",
            "id": f"mlflow-{random_id}",
            "displayName": f"mlflow-{random_id}-test",
            "instanceType": "cpu-1",
            "scope": "primehub"
        }
        logger.info('[ Test ] Create new PrimeHub app.')
        result = None
        try:
            result = self.ph.apps.create(config)
            logger.result(result)
            logger.success("[ OK ] Create new PrimeHub app.")
        except PrimeHubException as e:
            self.testing_error(
                "[ Error ] PrimeHub SDK error: {}".format(e))

        if result is not None:
            logger.info('[ Test ] Get PrimeHub app information.')
            try:
                app_information = self.ph.apps.get(result['id'])
                logger.result(app_information)
                assert app_information != {}, "Error"
                logger.success("[ OK ] Get PrimeHub app information.")
            except AssertionError:
                self.testing_error("[ Error ] Cannot get app service.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

            logger.info('[ Test ] Delete PrimeHub app.')
            try:
                delete_info = self.ph.apps.delete(result['id'])
                logger.result(delete_info)
                logger.success("[ OK ] Delete PrimeHub app.")
            except Exception:
                self.testing_error("[ Error ] Cannot delete app service.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

    def datasets_testing(self):
        """ datasets_testing: Check PrimeHub dataset can be used.
        """
        config = {
            "id": "test-dataset",
            "tags": ["test-dataset-tag", "training"]
        }
        logger.info("[ Test ] Create new dataset.")
        try:
            create_info = self.ph.datasets.create(config)
            logger.result(create_info)
            logger.success("[ OK ] Create new dataset.")
        except PrimeHubException as e:
            self.testing_error(
                "[ Error ] PrimeHub SDK error: {}".format(e))

        logger.info("[ Status ] Create new file: test.txt.")
        try:
            with open('test.txt', 'w') as f:
                f.write('Create a new text file!')
            logger.info("[ Done ] Create new file.")
        except Exception:
            self.testing_error("[ Error ] Fail to create test.txt file.")

        logger.info("[ Test ] Upload test.txt file.")
        try:
            upload_status = self.ph.datasets.files_upload(
                'test-dataset', 'test.txt', '/')
            logger.result(upload_status)
            logger.success("[ OK ] Upload test.txt file.")
        except PrimeHubException as e:
            self.testing_error(
                "[ Error ] PrimeHub SDK error: {}".format(e))

        logger.info("[ Status ] Remove the file: test.txt.")
        try:
            if os.path.exists("test.txt"):
                os.remove("test.txt")
                logger.info("[ Done ] Remove the file: test.txt.")
        except Exception:
            if os.path.exists("test.txt"):
                self.testing_error(
                    "[ Error ] Fail to remove the file: test.txt.")
            else:
                self.testing_error("[ Error ] The file is not existed.")

        logger.info("[ Test ] Get the dataset information by name.")
        dataset = None
        try:
            dataset = self.ph.datasets.get('test-dataset')
            logger.result(dataset)
            assert dataset != {}
            logger.success("[ OK ] Get the dataset information by name.")
        except AssertionError:
            self.testing_error("[ Error ] Cannot get dataset information.")
        except PrimeHubException as e:
            self.testing_error(
                "[ Error ] PrimeHub SDK error: {}".format(e))

        if dataset is not None:
            logger.info("[ Test ] Delete dataset.")
            try:
                delete_info = self.ph.datasets.delete(dataset['name'])
                logger.result(delete_info)
                logger.success("[ OK ] Successfully delete dataset.")
            except PrimeHubException as e:
                self.testing_error(
                    "[ Error ] PrimeHub SDK error: {}".format(e))

    def testing_error(self, error_info):
        """testing_error: Store error and output error message.
        """
        self.error.append("{}\n".format(error_info))
        logger.error(error_info)
