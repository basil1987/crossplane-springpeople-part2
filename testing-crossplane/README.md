## Check all the resources are READY

Step 1) Create your vpc subnets XR 

If you already have an XR. Go to step 2.

```
cd
cd cd crossplane-springpeople-part2/
git pull
cd compositions/crossplane-aws-provider/vpc-subnets/
kubectl apply -k .
cd
cd crossplane-springpeople-part2/examples/aws-provider-crossplane/composite-resources/vpc-subnets/
kubectl apply -k .
```

Make a note of the XR name by running below command. You need that name for step 2.

```
kubectl get composite
```

Step 2) - Test your XR
```
cd
cd crossplane-springpeople-part2
git pull
cd testing-crossplane
```

Now modify the file test.sh and replace "xvpcsubnet.network.springexample.io/xplane-vpc-subnets-rw2m8" with your XR. 

Once its done, run the test.

```
bash test.sh
```
