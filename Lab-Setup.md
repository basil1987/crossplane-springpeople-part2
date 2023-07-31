# Setting up Crossplane 

You need the following

1) An EC2 instance where we will run crossplane
2) An AWS account which will be managed by Crossplane.

### Pre-Requisites on the EC2 instance

1) Docker as a container runtime
2) K3D to setup a local kubernetes cluster
3) kubectl to talk to the cluster
4) Crossplane installed on the cluster
5) Crossplane providers - crossplane-aws-provider, upbound-aws-provider, kubernetes-provider, helm-provider
6) AWS Configurations using which Crossplane can manage your aws account.

1) Setting up Docker.

You can follow the official instructions to install Docker on the EC2 instance.=> https://docs.docker.com/engine/install/ubuntu/

A handy set of commands are given below.

```
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```


2) Install k3d and create a local Kubernetes Cluster

You can follow the documentation at https://k3d.io/

A handy set of commands are below.

```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create mycluster --agents=2
```


3) Install kubectl to talk to the cluster.

You can follow the documentation at https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/

A handy set of commands are below.

```
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```

Now run below command to verify the installation

```
kubectl get pods
```

You should see an output that looks like

```
root@ip-172-31-37-108:~# kubectl get pods
No resources found in default namespace.
root@ip-172-31-37-108:~#
```

If you get any warnings for "metrics.k8s.io/v1beta1" when running "kubectl get pods" command, restart docker.

```
service docker restart
```


4) Install Helm and Crossplane

You can install crossplane by following the documentation at https://docs.crossplane.io/latest/software/install/

Helm must be installed first. A documentation for the same is here => https://helm.sh/docs/intro/install/

A handy set of commands are below.

```
# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

# Install Crossplane
helm repo add crossplane-stable https://charts.crossplane.io/stable
helm repo update

helm install crossplane \
--namespace crossplane-system \
--create-namespace crossplane-stable/crossplane
```

Verify the crossplane installation by running below command. A sample output is also given below

```
root@ip-172-31-37-108:~# kubectl get deployments -n crossplane-system
NAME                      READY   UP-TO-DATE   AVAILABLE   AGE
crossplane-rbac-manager   1/1     1            1           20s
crossplane                1/1     1            1           20s
root@ip-172-31-37-108:~#
```


