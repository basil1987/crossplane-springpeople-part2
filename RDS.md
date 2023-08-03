## Aurora DB cluster with 2 DB instances, spread across 2 subnets ( availability zones )


1) Create the compositions.

```
cd
cd crossplane-springpeople-part2
git pull
cd compositions/crossplane-aws-provider/rds/
kubectl apply -f postgres-aurora.yaml
```


2) Modify the RDS claim and input the subnets.

If you do not have VPC and subnets, create them using below command.

```
cd
cd crossplane-springpeople-part2
git pull
cd compositions/crossplane-aws-provider/vpc-subnets/
kubectl apply -f .
## Please ignore any error if you got. 

# Create VPC
cd
cd crossplane-springpeople-part2
cd examples/aws-provider-crossplane/composite-resources/vpc-subnets
kubectl apply -f vpc-subnets-claim.yaml
```

Wait for subnets to become ready (2 mins). Once they become ready, get their subnet IDs, also find the VPC ID.

```
kubectl get subnet.ec2.aws.crossplane.io --show-labels
```

Copy 2 private subnet IDs, and the VPC IDs. You need them in the next step.


3) Modify your claim yaml file with the subnets and vpcs.

Add below lines to the rds claim

Modify the file examples/aws-provider-crossplane/composite-resources/rds/aurora-postgres.yaml and replace last 4 lines with below lines 

```
  subnetIds:
    - SUBNET1-ID
    - SUBNET2-ID
  vpcId: VPC-ID
```


4) Create the claim.

```
cd
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/rds
kubectl apply -f postgres-aurora.yaml
```



Verify the XR by running

```
kubectl get composite
```


5) Delete the Claim.

```
cd
cd crossplane-springpeople-part2
git pull
cd examples/aws-provider-crossplane/composite-resources/rds
kubectl delete -f postgres-aurora.yaml
```
