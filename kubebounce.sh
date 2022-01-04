#!/bin/bash
for n in $(kubectl get namespaces -o jsonpath={..metadata.name}); do
   kubectl delete pod --all -n $n
done
---
#!/bin/bash
deploys=`kubectl -n $1 get deployments | tail -n +2 | cut -d ' ' -f 1`
for deploy in $deploys; do
  kubectl -n $1 rollout restart deployments/$deploy
done

#参考链接
#https://qvault.io/2020/10/26/how-to-restart-all-pods-in-a-kubernetes-namespace/?utm_sq=gl06dz1viv
#https://github.com/lane-c-wagner/kubebounce
