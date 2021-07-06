# 安装csi-driver-nfs

1. 在Kubernetes集群上部署NFS服务器  
参考：https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/deploy/example/nfs-provisioner/README.md  
2. 在kubernetes集群上安装NFS CSI驱动主版本  
参考：https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver.md
3. 部署storageclass  
参考：https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/storageclass-nfs.yaml

```
#部署nfs csi驱动
kubectl apply -f .
#部署nfs服务器
kubectl apply -f nfs-server/.
#部署sc
kubectl apply -f storageclass/.
```
