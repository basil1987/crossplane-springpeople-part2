## Implementing GitOps for Cloud Infra

Pre-requisites

1) Flux installed on the Hub Cluster




#### 1) Install Flux on the Hub Cluster

Install the flux cli by following the doc at https://fluxcd.io/flux/installation/#install-the-flux-cli

Or you can run below handy command.

```
curl -s https://fluxcd.io/install.sh | sudo bash
```

Install flux and its components on the kubernetes cluster with below command.

```
flux install
```

#### 1) Create a GitRepository resource.

Run the below command to create a GitRepository for the podinfo project. 

```
cat <<EOF | kubectl apply -f -
apiVersion: source.toolkit.fluxcd.io/v1
kind: GitRepository
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 1m
  ref:
    branch: master
  url: https://github.com/basil1987/podinfo
EOF
```

#### 2) Create a kustomization 

```
cat <<EOF | kubectl apply -f -
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: podinfo
  namespace: flux-system
spec:
  interval: 1m0s
  path: ./kustomize
  prune: true
  retryInterval: 2m0s
  sourceRef:
    kind: GitRepository
    name: podinfo
  targetNamespace: default
  timeout: 3m0s
  wait: true
EOF
```

#### 3) Verify the podinfo app running. 

```
kubectl get all
```

