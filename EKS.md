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
