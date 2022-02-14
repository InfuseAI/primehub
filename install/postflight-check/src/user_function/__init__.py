import os
import uuid
from src.setup_logger import logger


class UserFunctionTesting:
    def __init__(self, ph):
        self.ph = ph
        self.error = []

    def testing_function_list(self, app_test, gpu_test):
        logger.info("[ Portal ] User Function Testing:")
        self.jobs_testing()
        self.datasets_testing()
        if gpu_test:
            self.gpu_testing()
        if app_test:
            self.apps_testing()
        return self.error

    def jobs_testing(self):
        # Submit a job
        logger.info("[ Status ] Submit the job and get the log.")
        config = {
            "instanceType": "cpu-1",
            "image": "base-notebook",
            "displayName": "short-job",
            "command": "echo \"test1\"\necho \"test2\"",
        }
        logger.info("[ Test ] Submit the job.")
        try:
            short_job = self.ph.jobs.submit(config)
            logger.debug(short_job)
            logger.success("[ OK ] Submit the job.")
        except Exception:
            self.testing_error("[ Error ] We cannot submit the job.")

        # Wait the job to be done
        logger.info('[ Test ] Waiting for job finishing.')
        try:
            wait_info = self.ph.jobs.wait(short_job['id'])
            logger.debug(wait_info)
            logger.success("[ OK ] Job is finishing.")
        except Exception:
            self.testing_error("[ Error ] Fail to wait for the job complete.")

        # Get logs
        logger.info('[ Test ] Get the job log.')
        try:
            logs = self.ph.jobs.logs(short_job['id'])
            log = list(logs)[0].decode("utf-8")
            logger.debug(log)
            logger.success("[ OK ] Successfully get the job log.")
        except AssertionError:
            self.testing_error("[ Error ] We cannot get the job log.")

        correct_message = ["test1", "test2", "Artifacts: no artifact found"]
        logger.info('[ Status ] Check the job log information.')
        try:
            for message in correct_message:
                assert message in log, "Error"
            logger.success("[ OK ] The log information is correct.")
        except Exception:
            self.testing_error("[ Error ] We get the wrong job log.")

    def gpu_testing(self):
        # Submit a job
        logger.info(
            "[ Status ] Submit the job and get the correct nvidia-smi log.")
        config = {
            "instanceType": "gpu-1",
            "image": "base-notebook",
            "displayName": "short-job",
            "command": "nvidia-smi",
        }
        logger.info("[ Test ] Submit the job.")
        try:
            short_job = self.ph.jobs.submit(config)
            logger.debug(short_job)
            logger.success("[ OK ] Submit the job.")
        except Exception:
            self.testing_error("[ Error ] We cannot submit the job.")

        # Wait the job to be done
        logger.info('[ Test ] Waiting for job finishing.')
        try:
            wait_info = self.ph.jobs.wait(short_job['id'])
            logger.debug(wait_info)
            logger.success("[ OK ] Job is finishing.")
        except Exception:
            self.testing_error("[ Error ] Fail to wait for the job complete.")

        # Get logs
        logger.info('[ Test ] Get the job log.')
        try:
            logs = self.ph.jobs.logs(short_job['id'])
            logger.success("[ OK ] Successfully get the job log.")
            all_logs = ''.join(list(logs)).decode("utf-8")
            logger.debug(all_logs)
        except AssertionError:
            self.testing_error("[ Error ] We cannot get the job log.")

        logger.info(
            '[ Test ] Check the job log contains nvidia-smi information.')
        try:
            assert "NVIDIA-SMI" in all_logs
            logger.success(
                '[ Ok ] Successfully get the nvidia-smi log information.')
        except AssertionError:
            self.testing_error("[ Error ] We get the wrong job log.")

    def apps_testing(self):
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
        try:
            result = self.ph.apps.create(config)
            logger.debug(result)
            logger.success("[ OK ] Create new PrimeHub app.")
        except Exception:
            self.testing_error("[ Error ] Cannot create app service.")

        logger.info('[ Test ] Get PrimeHub app information.')
        try:
            app_information = self.ph.apps.get(result['id'])
            logger.debug(app_information)
            assert app_information != {}, "Error"
            logger.success("[ OK ] Get PrimeHub app information.")
        except Exception:
            self.testing_error("[ Error ] Cannot get app service.")

        logger.info('[ Test ] Delete PrimeHub app.')
        try:
            delete_info = self.ph.apps.delete(result['id'])
            logger.debug(delete_info)
            logger.success("[ OK ] Delete PrimeHub app.")
        except Exception:
            self.testing_error("[ Error ] Cannot delete app service.")

    def datasets_testing(self):
        config = {
            "id": "test-dataset",
            "tags": ["test-dataset-tag", "training"]
        }
        logger.info("[ Test ] Create new dataset.")
        try:
            create_info = self.ph.datasets.create(config)
            logger.debug(create_info)
            logger.success("[ OK ] Create new dataset.")
        except Exception:
            self.testing_error("[ Error ] Cannot create new dataset.")

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
            logger.debug(upload_status)
            logger.success("[ OK ] Upload test.txt file.")
        except Exception:
            self.testing_error("[ Error ] Cannot upload file to dataset.")

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
        try:
            dataset = self.ph.datasets.get('test-dataset')
            logger.debug(dataset)
            assert dataset != {}
            logger.success("[ OK ] Get the dataset information by name.")
        except Exception:
            self.testing_error("[ Error ] Cannot get dataset information.")

        logger.info("[ Test ] Delete dataset.")
        try:
            delete_info = self.ph.datasets.delete(dataset['name'])
            logger.success("[ OK ] Successfully delete dataset.")
        except Exception:
            self.testing_error("[ Error ] Cannot delete dataset.")

    def testing_error(self, error_info):
        self.error.append("{}\n".format(error_info))
        logger.error(error_info)
