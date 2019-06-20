# Contributing to PrimeHub

Issues and PRs are welcome!

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
