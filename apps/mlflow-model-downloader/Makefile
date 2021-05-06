VERSION := v0.1.0
IMAGE_NAME_BASE=mlflow-model-downloader
IMAGE_BASE=infuseai/${IMAGE_NAME_BASE}

build:
	docker build . -t ${IMAGE_BASE}:${VERSION}

push:
	docker push ${IMAGE_BASE}:${VERSION}

