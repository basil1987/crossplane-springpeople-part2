## Create a EKS Cluster in AWS


1) Create the subnet compositions.


```
git clone https://github.com/basil1987/crossplane-springpeople-part2.git
cd crossplane-springpeople-part2
cd compositions/crossplane-aws-provider/vpc-subnets
kubectl apply -f .
```


2) Verify above by creating XR through a claim


```
cd 
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/vpc-subnets
kubectl apply -f vpc-subnets-claim.yaml
```

Wait for sometime and XR will be ready. To verify

```
kubectl get composite
```

3) Delete the claim and XR

```
cd 
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/vpc-subnets
kubectl delete -f vpc-subnets-claim.yaml
```

4) Create the EKS compositions.


```
cd
cd crossplane-springpeople-part2
git pull
cd compositions/crossplane-aws-provider/eks
kubectl apply -f definition.yaml
kubectl apply -f eks-managed-node-group.yaml
kubectl apply -f eks-managed-node-group-subnet-labels.yaml
kubectl apply -f autoscaler.yaml
```


5) Create a VPC and EKS Cluster using the composition xamazonekss.cluster.springexample.io

Create the VPC.

```
cd 
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/vpc-subnets
kubectl apply -f vpc-subnets-claim.yaml
```

Wait for the composite resource to become READY (READY=true). It may take upto 2 mins.

```
kubectl get composite
```

Once they become ready, make a note of the private subnet IDs by running below command.

```
kubectl get subnets.ec2.aws.crossplane.io --show-labels
```

Above command will show 6 subnets. 3 will be private and 3 will be public. Copy the subnet IDs of the 3 private subnets and paste them into your EKS claim file "eks-claim.yaml" located under the folder examples/aws-provider-crossplane/composite-resources/eks/ by modifying line numbers 47, 48, 49

Now create the EKS Cluster by running below commands.


```
cd 
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/eks
# eks-claim.yaml line numbers 47, 48, 49 must be updated with subnet IDs.
kubectl apply -f eks-claim.yaml
```

Run this command and wait for READY=True which may take 15 to 20 minutes. 

```
kubectl get composite
```


6) Delete the claim and XR for EKS

```
cd 
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/eks
kubectl delete -f eks-claim.yaml
```

It may take some time for the cluster to completely delete. 



7) Create an EKS Autoscaler claim


```
cd 
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/eks
kubectl apply -f 
```
