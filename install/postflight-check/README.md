# PrimeHub SDK post-flight check automation.

## Build the postflight check docker image.

If you want to build up postflight check docker images, then please use the following commend line to build image.

```docker build -t primehub-postflight-check:v0.0.4 -f ./docker/Dockerfile .```

## Run the postflight check image

### Minimum check

```docker run -it primehub-postflight-check:v0.0.4 /bin/bash -c "python main.py --primehub_cluster <domain-ip>"```

### Optional

1. --app Test PrimeHub App.

```docker run -it primehub-postflight-check:v0.0.4 /bin/bash -c "python main.py --primehub_cluster <domain-ip> --app"```

2. --gpu Test gpu device.

```docker run -it primehub-postflight-check:v0.0.4 /bin/bash -c "python main.py --primehub_cluster <domain-ip> --gpu"```