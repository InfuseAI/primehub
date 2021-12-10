![logo](docs/media/logo.png?raw=true "PrimeHub")

[![GitHub release](https://img.shields.io/github/release/infuseAI/primehub/all.svg?style=flat-square)](https://github.com/infuseAI/primehub/releases)
[![FOSSA Status](https://app.fossa.com/api/projects/git%2Bgithub.com%2FInfuseAI%2Fprimehub.svg?type=shield)](https://app.fossa.com/projects/git%2Bgithub.com%2FInfuseAI%2Fprimehub?ref=badge_shield)
[![CircleCI](https://circleci.com/gh/InfuseAI/primehub.svg?style=shield)](https://circleci.com/gh/InfuseAI/primehub)
[![codecov](https://codecov.io/gh/InfuseAI/primehub/branch/master/graph/badge.svg?token=WOO4EXU96F)](https://codecov.io/gh/InfuseAI/primehub)
[![InfuseAI Discord Invite](https://img.shields.io/discord/664381609771925514?color=%237289DA&label=chat&logo=discord&logoColor=white)](https://discord.com/invite/5zb2aK9KBV)
[![Open In Colab](https://colab.research.google.com/assets/colab-badge.svg)](https://colab.research.google.com/github/InfuseAI/primehub-demo-notebooks/blob/main/primehub-sdk-mlops/mlops.ipynb)


# PrimeHub Community Edition

[![Launch Stack](https://us-east-1.console.aws.amazon.com/cloudformation/home?region=us-east-1#/stacks/create/review?stackName=primehub-starter&templateURL=https://primehub.s3.amazonaws.com/cloudformation/v1.1.3/primehub-ce-starter-cloudformation.yaml)]

Welcome to the PrimeHub Community Edition repository, **PrimeHub** is an effortless infrastructure for machine learning built on the top of Kubernetes. It provides *cluster-computing*, *one-click research environments*, *easy dataset loading*, and *management of various resources* and *access-control*. All of these are designed from *a project/team-centric* concept.

In terms of **PrimeHub CE**, it provides a few fundamental features from [Enterprise Edition↗](https://www.infuseai.io/primehub).

To IT leaders, PrimeHub gives flexibility and administration authority to configure resources and settings for their teams, as well as to pave the way and manage productionized workloads.

To Data scientists, PrimeHub provides Jupyter Notebook-ready environment which is just few-clicks away.

This community repository contains a *Helm Chart* for PrimeHub CE and a guide on how to install PrimeHub CE with *Helm*.

## Fundamental Features

- Opinionated JupyterHub distribution
- Group & user based resource management
- Instance, image & secret management
- Support different types of dataset
- Dataset uploader
- SSH server (allow access into JupyterHub via *ssh* remotely)

### What makes PrimeHub different

Please see the [comparison](Comparison.md).

## Installation

Please see the [installation guide↗](https://docs.primehub.io/docs/getting_started/install_primehub_ce).

### The scenario on Katacoda

Prefer a trial run before getting into a real installation!?

Please visit our [installation scenario on Katacoda↗](https://www.katacoda.com/infuseai) to feel it.

## Contributions

We welcome contributions. See the [Set up dev environment](DEVELOP.md) and the [Contributing guildline](CONTRIBUTING.md) to get started.

## Project Status

PrimeHub CE is released alongside PrimeHub EE. The project has been developed steadily. We keep improving PrimeHub's robustness, enhancing user experience and are releasing [more features](https://docs.primehub.io/docs/next/comparison) with the community. Suggestions and discussions are always welcome and
appreciated.

## Documentation

### Designs & Concepts

PrimeHub is built on top of well-designed distributed systems. We use Kubernetes as the orchestration platform and utilize its resource management and fault-tolerance abilities.

You can read more about the [designs & concepts of PrimeHub ↗](https://docs.primehub.io/docs/design/architecture) or visit our [documentation↗](https://docs.primehub.io/) site to learn more about PrimeHub.
