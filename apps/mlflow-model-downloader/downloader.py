import os
import sys

import mlflow
from mlflow.tracking.artifact_utils import _download_artifact_from_uri


def get_tracking_uri():
    uri = os.environ.get("MLFLOW_TRACKING_URI")
    if not uri:
        raise ValueError("env MLFLOW_TRACKING_URI is required")
    return uri


def get_output_path():
    output_path = os.environ.get("OUTPUT_PATH")
    if not output_path:
        output_path = "/mnt/models"

    import pathlib
    pathlib.Path(output_path).mkdir(parents=True, exist_ok=True)
    return output_path


def wait_for_exit():
    time_to_wait = os.environ.get("WAIT_FOR_EXIT")
    if time_to_wait:
        try:
            import time
            s = int(time_to_wait)
            print("sleep {} seconds".format(s))
            time.sleep(s)
        except:
            pass


def main(model_uri):
    tracking_uri = get_tracking_uri()
    output_path = get_output_path()
    print("set tracking uri: {}".format(tracking_uri))
    print("save to path: {}".format(output_path))

    mlflow.set_tracking_uri(tracking_uri)
    _download_artifact_from_uri(artifact_uri=model_uri, output_path=output_path)

    wait_for_exit()


if __name__ == '__main__':
    if not sys.argv[1:]:
        print("model_uri should be the first argument")
    else:
        main(sys.argv[1])
