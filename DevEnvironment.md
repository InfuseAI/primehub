# Setting up development environment

0. You can download required tools using our [kubernetes-starterkit](https://github.com/InfuseAI/kubernetes-starterkit).

1. Prepare your Kubernetes cluster for development.

2. Install nginx-ingress if necessary.

   ```
    helm repo add stable https://charts.helm.sh/stable
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

   cat <<EOF > primehub.yaml
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
     --values primehub.yaml

   ```

## Other PrimeHub Components

PrimeHub consists several other components, you may also want to check out these repositories.

For developing locally with each components, please refer to the `DEVELOP.md` in each repositories.

### PrimeHub Console

- https://github.com/InfuseAI/primehub-console

PrimeHub Console contains the admin UI and GraphQL API server of PrimeHub.

### PrimeHub Admission

- https://github.com/InfuseAI/primehub-admission

PrimeHub-admission is a critical component of PrimeHub. It's responsible for validating resource capacity and mutating kubernetes objects with required information.

### PrimeHub Controller

- https://github.com/InfuseAI/primehub-controller

PrimeHub-controller handles advanced features like image builder, job submission...etc. It watches PrimeHub CRDs and do the magic for you.
