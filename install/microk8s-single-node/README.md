# Microk8s single node PrimeHub platform installation

The document is easy way to install PrimeHub on single node Microk8s kubernetes system.

# How to use it?

## Step 1

- Please put the `microk8s-install-primehub.sh` file into `$HOME` directory.

## Step 2

- Run the command:

```bash
$ chmod 777 ./microk8s-install-primehub.sh
$ ./microk8s-install-primehub.sh <cluster-url> <keycloak-password> <primeHub-password>
```