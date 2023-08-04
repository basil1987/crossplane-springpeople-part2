# load array into a bash array
# need to output each entry as a single line

MY_XR="xvpcsubnet.network.springexample.io/xplane-vpc-subnets-rw2m8"
kubectl get $MY_XR -o yaml > test.yml

readarray resourceRefs < <(yq e -o=j -I=0 '.spec.resourceRefs[]' test.yml )

for resourceRefs in "${resourceRefs[@]}"; do
    # identity mapping is a yaml snippet representing a single entry
    apiVersion=$(echo "$resourceRefs" | yq e '.apiVersion' - | cut -d/ -f1)
    kind=$(echo "$resourceRefs" | yq e '.kind' -)
    name=$(echo "$resourceRefs" | yq e '.name' -)
    kubectl get $kind.$apiVersion/$name | grep False
    if [ $? -eq 0 ]; then
            echo "$kind.$apiVersion/$name is NOT ready"
            kubectl describe $kind.$apiVersion/$name
    fi
done
