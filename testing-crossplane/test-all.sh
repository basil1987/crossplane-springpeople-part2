for xr in `kubectl get composite | awk '{print $1}' | grep -v NAME`; 
do 
bash test.sh $xr ; 
done
