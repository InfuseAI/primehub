![logo](docs/media/logo.png?raw=true "PrimeHub")

[![GitHub release](https://img.shields.io/github/release/infuseAI/primehub/all.svg?style=flat-square)](https://github.com/infuseAI/primehub/releases)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FInfuseAI%2Fprimehub.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FInfuseAI%2Fprimehub?ref=badge_shield)
[![CircleCI](https://circleci.com/gh/InfuseAI/primehub.svg?style=svg)](https://circleci.com/gh/InfuseAI/primehub)

# PrimeHub Community Edition

Welcome to PrimeHub Community Edition repository, **PrimeHub** is an effortless infrastructure for machine learning built on the top of Kubernetes. It provides *cluster-computing*, *one-click research environment*, *easy dataset loading*, *management of various resources* and *access-control*. All of these are designed from *project/team-centric* concept. 

In terms of **PrimeHub CE**, it provides a few fundamental features from [Enterprise Edition](https://www.infuseai.io/).

To IT leaders, PrimeHub gives flexibility and administration authority to configure resources and settings for their teams, as well as to pave the way and manage productionized workloads.

To Data scientists, PrimeHub provides JupyterHub-ready environment which is just few-clicks away.

In this community repository, it contains a *Helm Chart* to PrimeHub CE and a guide of PrimeHub CE installation by *Helm*.

## Fundamental Features

- Opinionated JupyterHub distribution
- Group & user based resource management
- Instance, image & secret management
- Support different types of dataset
- Dataset uploader
- SSH server (allow access into JupyterHub via *ssh* remotely)

### What makes PrimeHub different

Please see the [comparison](Comparison.md).

### Designs & Concepts

Primehub is built on top of well-designed distributed systems. We use Kubernetes as the orchestration platform and utilize its resource management and fault-tolerance abilities.

You can read more about the designs & concepts of PrimeHub [here](https://docs.primehub.io/docs/design/architecture).

## Installation

Please see the [installation guide](INSTALL.md).

### The scenario on Katacoda

Prefer a trial run before getting into a real installation!?

Please visit our [installation scenario on Katacoda](https://www.katacoda.com/infuseai) to feel it.

## Contributions

We welcome contributions. See the [Contributing guildline](CONTRIBUTING.md) to get started.

### Setting up development environment

0. You can download required tools using our [kubernetes-starterkit](https://github.com/InfuseAI/kubernetes-starterkit)

1. Prepare your Kubernetes cluster for development.

2. Install nginx-ingress if necessary.

   ```
    helm repo add stable https://kubernetes-charts.storage.googleapis.com
    helm install nginx-ingress stable/nginx-ingress --create-namespace --namespace nginx-ingress --version=1.31.0 --set controller.hostNetwork=true
    kubectl apply -f k3d/nginx-config.yaml
   ```

3. Clone the PrimeHub repo

   ```
   git clone git@github.com:InfuseAI/primehub.git
   cd primehub
   ```

3. Update git submodules

   ```
   git submodule update --init
   ```

4. Install primehub by local chart

   ```
   PRIMEHUB_DOMAIN=1.2.3.4.nip.io # fill the correct domain according to your dev environment

   cat <<EOF > primehub-values.yaml
   primehub:
   domain: ${PRIMEHUB_DOMAIN}
   ingress:
   annotations:
   kubernetes.io/ingress.allow-http: "true"
   nginx.ingress.kubernetes.io/ssl-redirect: "false"
   hosts:
   -  ${PRIMEHUB_DOMAIN}
   EOF

   helm upgrade \
     primehub chart \
     --install \
     --create-namespace \
     --namespace hub  \
     --values primehub-values.yaml

   ```

### Other PrimeHub Components

PrimeHub consists several other components, you may also want to check out these repositories.

#### PrimeHub Console

- https://github.com/InfuseAI/primehub-console

PrimeHub Console contains the admin UI and GraphQL API server of PrimeHub.

#### PrimeHub Admission

- https://github.com/InfuseAI/primehub-admission

PrimeHub-admission is a critical component of PrimeHub. It's responsible for validating resource capacity and mutating kubernetes objects with required information.

## Project Status

PrimeHub CE is released along with PrimeHub EE. The project has been developed steadily. We keeps improving robustness, enhancing user experience and releasing [more features](https://docs.primehub.io/docs/next/comparison) with the community. Suggestions and discussions are welcome and
appreciated.

## Documentation

Please visit our [documentation](https://docs.primehub.io/) site to learn more about PrimeHub.
