# Setting up Crossplane 

You need the following

1) An EC2 instance where we will run crossplane
2) An AWS account which will be managed by Crossplane.

### Pre-Requisites on the EC2 instance

1) Docker as a container runtime
2) K3D to setup a local kubernetes cluster
3) kubectl to talk to the cluster
4) Crossplane installed on the cluster
5) Install Crossplane providers - crossplane-aws-provider, upbound-aws-provider, kubernetes-provider, helm-provider
6) Configure Crossplane providers
7) Test everything.

#### 1) Setting up Docker.

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


#### 2) Install k3d and create a local Kubernetes Cluster

You can follow the documentation at https://k3d.io/

A handy set of commands are below.

```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
k3d cluster create mycluster --agents=2
```


#### 3) Install kubectl to talk to the cluster.

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


#### 4) Install Helm and Crossplane

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


#### 5) Install Crossplane Providers.

We will be using following providers. 

aws-provider (by Crossplane)
aws-provider (by Upbound)
kubernetes-provider
helm-provider 

The aws-provider come with a handly list of resources and controllers to manage resources in your aws account. 

The kubernetes and helm providers can be used for running applications on Kubernetes Clusters. 

5.1) aws-provider (by Crossplane) => https://marketplace.upbound.io/providers/crossplane-contrib/provider-aws

```
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-crossplane
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-aws:v0.42.0
EOF
```

5.2) aws-provider (by Upbound) => https://marketplace.upbound.io/providers/upbound/provider-aws/

```
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-aws-upbound
spec:
  package: xpkg.upbound.io/upbound/provider-aws:v0.37.0
EOF
```

5.3) kubernetes provider (By Crossplane) => https://marketplace.upbound.io/providers/crossplane-contrib/provider-kubernetes

```
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-kubernetes
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-kubernetes:v0.9.0
EOF
```

5.4) Helm Provider (By Crossplane) => https://marketplace.upbound.io/providers/crossplane-contrib/provider-helm/ 

```
cat <<EOF | kubectl apply -f -
apiVersion: pkg.crossplane.io/v1
kind: Provider
metadata:
  name: provider-helm
spec:
  package: xpkg.upbound.io/crossplane-contrib/provider-helm:v0.15.0
EOF
```


#### 6) Configure Crossplane Providers.


6.1) Storing AWS Credentials as secret in Kubernetes.

  A User must create his AWS Credentials and store them as a secret in the kubernetes. Then you can create a providerConfig in Crossplane using that secret. This will configure the provider to connect to AWS.
  
  Login to your AWS Account > Go to IAM > Select the User > Click on "Security Credentials" > Click on "Create Access Key" under "Access keys". > Select "Command Line Interface (CLI)" and NEXT > Create Access Key.
  
  Now copy those credentials somewhere. You need to save these credentials as a secret in kubernetes. Create a file with name "aws_credentials.txt" on your EC2 instance with following content.
  
  ```
  [default]
  aws_access_key_id=YOUR_ACCESS_KEY
  aws_secret_access_key=YOUR_SECRET_KEY
  region=ap-northeast-1
  ```
  
  Now save this file inside Kubernetes as a secret named "aws-secret" under key "creds". Run below command 
  
  ```
  kubectl create secret \
  generic aws-secret \
  -n crossplane-system \
  --from-file=creds=./aws_credentials.txt
  ```

6.2) Creating provider Configurations for AWS Providers.

  The secret created in previous steps will be referred by your provider configuration. 
  
  ###### Create provider configuration for aws provider by crossplane. 
  
```
cat <<EOF | kubectl apply -f -
      apiVersion: aws.crossplane.io/v1beta1
      kind: ProviderConfig
      metadata:
          name: default
      spec:
        credentials:
          source: Secret
          secretRef:
            namespace: crossplane-system
            name: aws-secret
            key: creds
EOF
```
  
  ###### Create provider configuration for aws provider by Upbound.
  
```
cat <<EOF | kubectl apply -f -
      apiVersion: aws.upbound.io/v1beta1
      kind: ProviderConfig
      metadata:
          name: default
      spec:
        credentials:
          source: Secret
          secretRef:
            namespace: crossplane-system
            name: aws-secret
            key: creds
EOF
```

6.3) Creating provider configurations for kubernetes and helm providers.

   ##### Kubernetes Provider in-cluster configuration

```
cat <<EOF | kubectl apply -f -
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: ProviderConfig
metadata:
  name: kubernetes-provider
spec:
  credentials:
    source: InjectedIdentity
EOF
```

   Please note that the kubernetes provider runs in the namespace "crossplane-system". Make sure that the service account is given necessary permissions on the cluster (clusterAdmin in this example). Run below commands.

```
SA=$(kubectl -n crossplane-system get sa -o name | grep provider-kubernetes | sed -e 's|serviceaccount\/|crossplane-system:|g')
kubectl create clusterrolebinding provider-kubernetes-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}"
kubectl apply -f examples/provider/config-in-cluster.yaml
```

   ##### Helm Provider in-cluster configuration

```
cat <<EOF | kubectl apply -f -
apiVersion: helm.crossplane.io/v1beta1
kind: ProviderConfig
metadata:
  name: helm-provider
spec:
  credentials:
    source: InjectedIdentity
EOF
```

   Please note that the helm provider runs in the namespace "crossplane-system". Make sure that the service account is given necessary permissions on the cluster (clusterAdmin in this example). Run below commands.

```
SA=$(kubectl -n crossplane-system get sa -o name | grep provider-helm | sed -e 's|serviceaccount\/|crossplane-system:|g')
kubectl create clusterrolebinding provider-helm-admin-binding --clusterrole cluster-admin --serviceaccount="${SA}"
kubectl apply -f examples/provider-config/provider-config-incluster.yaml
```


#### 7) Test Everything.

7.1) AWS Provider by Crossplane 

Create a bucket in your aws account using below command.

```
bucket=$(echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10))
CAT <<EOF | kubectl apply -f -
apiVersion: s3.aws.crossplane.io/v1beta1
kind: Bucket
metadata:
  name: $bucket
spec:
  deletionPolicy: Delete
  forProvider:
    locationConstraint: us-east-1
    objectOwnership: BucketOwnerEnforced
    paymentConfiguration:
      payer: BucketOwner
    versioningConfiguration:
      status: Enabled
  providerConfigRef:
    name: default
EOF
```

7.2) AWS Provider by Upbound 

Create a bucket in your aws account using below command.

```
bucket=$(echo "upbound-bucket-"$(head -n 4096 /dev/urandom | openssl sha1 | tail -c 10))
CAT <<EOF | kubectl apply -f -
apiVersion: s3.aws.upbound.io/v1beta1
kind: Bucket
metadata:
  name: $bucket
spec:
  forProvider:
    region: us-east-1
  providerConfigRef:
    name: default
EOF
```

7.3) Kubernetes Provider 

Create a configmap by running below command.

```
CAT <<EOF | kubectl apply -f -
apiVersion: kubernetes.crossplane.io/v1alpha1
kind: Object
metadata:
  name: foo
spec:
  forProvider:
    manifest:
      apiVersion: v1
      kind: ConfigMap
      metadata:
        namespace: default
  managementPolicy: ObserveDelete
  providerConfigRef:
    name: kubernetes-provider
EOF
```

7.4) Helm Provider 

Create a wordpress release 

```
CAT <<EOF | kubectl apply -f -
apiVersion: helm.crossplane.io/v1beta1
kind: Release
metadata:
  name: wordpress-example
spec:
  forProvider:
    chart:
      name: wordpress
      repository: https://charts.bitnami.com/bitnami
      version: 15.2.5
    namespace: wordpress
    set:
      - name: param1
        value: value2
    values:
      service:
        type: ClusterIP
  providerConfigRef:
    name: helm-provider
EOF
```

Wait for sometime and run below command to confirm that READY=True 

```
kubectl get managed
```

