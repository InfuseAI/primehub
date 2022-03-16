# PrimeHub SDK post-flight check automation.

## Build the postflight check docker image.

If you want to build up postflight check docker images, then please use the following commend line to build image.

```docker build -t primehub-postflight-check:v0.1.0 -f ./docker/Dockerfile .```

## Run the postflight check docker container.

### Minimum check

```docker run -it primehub-postflight-check:v0.1.0 /bin/bash -c "python main.py"```

When you run the postflight check, please answer the question to do the environment setting.
```bash
2022-03-16 09:22:11 [INFO] Please answer the following question:
primehub cluster URL: <primehub_cluster_url>
Does the cluster node contain GPU device? (y/n) y
Does the cluster install Grafana Dashboard? (y/n) y
```

### Optional

1. --app: Test PrimeHub App.

```docker run -it primehub-postflight-check:v0.1.0 /bin/bash -c "python main.py --app"```

2. --primehub_ce: The PrimeHub edition is community edition.

```docker run -it primehub-postflight-check:v0.1.0 /bin/bash -c "python main.py --primehub_ce"```

3. --sdk_group: If you want to change SDK group, then you can use this tag to change the PrimeHub group.

```docker run -it primehub-postflight-check:v0.1.0 /bin/bash -c "python main.py --sdk_group test"```

### Environment variable

- If the PrimeHub environment is not the fresh installation status, then we can change the environment to fit the real world case.

- Variable:
```config
basic_group_list='["phuser"]'
basic_instance_list='["cpu-1", "cpu-2", "gpu-1", "gpu-2"]' 
basic_image_list='["base-notebook", "pytorch-1", "tf-1", "tf-2"]' 
basic_secret_list='[]' 
basic_volume_list='[]' 
```

- Command line:
```bash
docker run \
-e basic_group_list='["phuser"]'\
-e basic_instance_list='["cpu-1", "cpu-2", "gpu-1", "gpu-2"]' \
-e basic_image_list='["base-notebook", "pytorch-1", "tf-1", "tf-2"]' \
-e basic_secret_list='[]' \
-e basic_volume_list='[]' \
-it primehub-postflight-check:v0.0.1 \
/bin/bash -c "python main.py"
```