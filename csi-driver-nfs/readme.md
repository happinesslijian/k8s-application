# 安装csi-driver-nfs

1. 在Kubernetes集群上部署NFS服务器   
参考：https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/deploy/example/nfs-provisioner/README.md  
2. 在kubernetes集群上安装NFS CSI驱动主版本   
参考：https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-master.md
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

## 题外话
- 如下两个image在国内拉取不了,采用了Googlecloud拉取并推送到阿里云上
```
docker pull k8s.gcr.io/sig-storage/csi-provisioner:v2.1.0
docker pull k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.2.0
```
```
docker tag k8s.gcr.io/sig-storage/csi-provisioner:v2.1.0 registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-provisioner:v2.1.0
docker tag k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.2.0 registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-node-driver-registrar:v2.2.0
```
```
docker push registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-provisioner:v2.1.0
docker push registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-node-driver-registrar:v2.2.0
```
- 单位集群cri使用的是containerd,需要从阿里云上把刚才的image拉下来
```
crictl pull --creds 李健happiness:password registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-provisioner:v2.1.0
crictl pull --creds 李健happiness:password registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-node-driver-registrar:v2.2.0
```
- 查看images
```
crictl images ls
```
### containerd貌似不支持修改tag  
- 改成需要的k8s.gcr.io/sig-storage/csi-provisioner:v2.1.0和k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.2.0    
```
~~ctr images tag registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-provisioner:v2.1.0 k8s.gcr.io/sig-storage/csi-provisioner:v2.1.0~~  
~~ctr image tag registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-node-driver-registrar:v2.2.0 k8s.gcr.io/sig-storage/csi-node-driver-registrar:v2.2.0~~
```

- 推送到阿里云
```
ctr images pull --plain-http --user 李健happiness:password registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/csi-provisioner:v2.1.0
```

## 产生的疑问
如果使用containerd作为集群的cri没办法改tag我想到两种解决办法：  
1. 直接给linux挂代理。让机器可以直接pull国外的images  
2. 针对要部署的项目,手动更改*.yaml文件里的images改成国内的  
```
#linux翻墙：
vim /etc/profile/
http_proxy=10.110.xx.xx:8118
https_proxy=$http_proxy
export http_proxy https_proxy
#刷新环境变量
source /etc/profile
```
