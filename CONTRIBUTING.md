# Contributing to PrimeHub

Issues and PRs are welcome!

# Developer Certificate of Origin

PrimeHub DCO and signed-off-by process

The PrimeHub project use the signed-off-by language and process used by the Linux kernel, to give us a clear chain of trust for every patch received.

```
By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I have the right to submit it under the open source license indicated in the file; or

(b) The contribution is based upon previous work that, to the best of my knowledge, is covered under an appropriate open source license and I have the right under that license to submit that work with modifications, whether created in whole or in part by me, under the same open source license (unless I am permitted to submit under a different license), as indicated in the file; or

(c) The contribution was provided directly to me by some other person who certified (a), (b) or (c) and I have not modified it.

(d) I understand and agree that this project and the contribution are public and that a record of the contribution (including all personal information I submit with it, including my sign-off) is maintained indefinitely and may be redistributed consistent with this project or the open source license(s) involved.
```

## Using the Signed-Off-By Process

We have the same requirements for using the signed-off-by process as the Linux kernel. In short, you need to include a signed-off-by tag in every patch:

```
This is my commit message

Signed-off-by: Random J Developer <random@developer.example.org>
```

Git even has a -s command line option to append this automatically to your commit message:

```
$ git commit -s -m 'This is my commit message'
```

# Setting up development environment
1. Follow the instruction in [getting started](docs/getting_started.md) to install PrimeHub locally.
2. Clone the PrimeHub repo

   ```
   git clone git@github.com:InfuseAI/primehub.git
   cd primehub
   ```

3. Update the chart dependencies

   ```
   helm repo add stable https://kubernetes-charts.storage.googleapis.com/
   helm repo add jupyterhub https://jupyterhub.github.io/helm-chart/
   helm dependency update helm/primehub
   ```

4. Install primehub by local chart

   ```
   helm upgrade --install primehub \
       --namespace primehub \
       --values values.yaml \
       --set-file jupyterhub.hub.extraConfig.primehub=./helm/primehub/jupyterhub_primehub.py \
       ./helm/primehub
   ```
