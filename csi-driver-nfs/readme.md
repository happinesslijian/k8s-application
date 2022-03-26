# csi-driver-nfs

[本文参考链接](https://github.com/kubernetes-csi/csi-driver-nfs)  
[本文参考链接](https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/deploy/example/nfs-provisioner/README.md)  
[本文参考链接](https://github.com/kubernetes-csi/csi-driver-nfs/blob/master/docs/install-csi-driver-v3.1.0.md)

# 概述:
这是[NFS](https://en.wikipedia.org/wiki/Network_File_System) [CSI](https://kubernetes-csi.github.io/docs/)驱动程序的存储库，csi 插件名称：nfs.csi.k8s.io. 此驱动程序需要现有且已配置的 NFSv3 或 NFSv4 服务器，它通过在 NFS 服务器下创建新的子目录来支持通过持久卷声明动态配置持久卷。

### 环境介绍：
| 名称 | 集群版本 | 节点角色 | 安装方式 | 系统版本 |
| :--: | :--: | :--: | :--: | :--: |
| node1 | v1.19.4 | control-plane,etcd,master | kubeadm | CentOS Linux release 7.6.1810 (Core) |
| node2 | v1.19.4 | control-plane,etcd,master | kubeadm | CentOS Linux release 7.6.1810 (Core) |
| node3 | v1.19.4 | control-plane,etcd,master | kubeadm | CentOS Linux release 7.6.1810 (Core) |
| node4 | v1.19.4 | worker | kubeadm | CentOS Linux release 7.6.1810 (Core) |
| node5 | v1.19.4 | worker | kubeadm | CentOS Linux release 7.6.1810 (Core) |

> **须知：**
前提确保所有的服务器上都安装了[nfs](https://github.com/happinesslijian/VM/tree/master/VM%E5%AE%89%E8%A3%85nfs/%E5%AE%89%E8%A3%85)

1 要在 Kubernetes 集群上创建 NFS 配置器，请运行以下命令
```
kubectl create -f https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/deploy/example/nfs-provisioner/nfs-server.yaml
```
2 在kubernetes集群上安装NFS CSI驱动v3.1.0版本
```
curl -skSL https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/v3.1.0/deploy/install-driver.sh | bash -s v3.1.0 --
```
3 检查pod状态
```
kubectl -n kube-system get pod -o wide -l app=csi-nfs-controller
kubectl -n kube-system get pod -o wide -l app=csi-nfs-node
```
4 使用方式
> **说明：**  
我部署了prometheus 并使用了storageclass
贴上`storageclass.yaml`配置
```
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: prometheus
provisioner: nfs.csi.k8s.io
parameters:
  server: nfs-server.default.svc.cluster.local
  share: /
  # csi.storage.k8s.io/provisioner-secret is only needed for providing mountOptions in DeleteVolume
  # csi.storage.k8s.io/provisioner-secret-name: "mount-options"
  # csi.storage.k8s.io/provisioner-secret-namespace: "default"
reclaimPolicy: Delete
volumeBindingMode: Immediate
mountOptions:
#  - nconnect=8
  - hard
  - nfsvers=4.1
```
`prometheus-prometheus.yaml`关联名为`prometheus`的`storageclass` 如下
```
apiVersion: monitoring.coreos.com/v1
kind: Prometheus
metadata:
  labels:
    app.kubernetes.io/component: prometheus
    app.kubernetes.io/instance: k8s
    app.kubernetes.io/name: prometheus
    app.kubernetes.io/part-of: kube-prometheus
    app.kubernetes.io/version: 2.34.0
  name: k8s
  namespace: monitoring
spec:
  alerting:
    alertmanagers:
    - apiVersion: v2
      name: alertmanager-main
      namespace: monitoring
      port: web
  enableFeatures: []
  externalLabels: {}
  image: quay.io/prometheus/prometheus:v2.34.0
  nodeSelector:
    kubernetes.io/os: linux
  podMetadata:
    labels:
      app.kubernetes.io/component: prometheus
      app.kubernetes.io/instance: k8s
      app.kubernetes.io/name: prometheus
      app.kubernetes.io/part-of: kube-prometheus
      app.kubernetes.io/version: 2.34.0
  podMonitorNamespaceSelector: {}
  podMonitorSelector: {}
  probeNamespaceSelector: {}
  probeSelector: {}
  replicas: 2
  resources:
    requests:
      memory: 400Mi
  ruleNamespaceSelector: {}
  ruleSelector: {}
#以下部分用于关联storageclass
  securityContext:
    fsGroup: 2000
    runAsNonRoot: true
    runAsUser: 1000
  storage:
    volumeClaimTemplate:
      spec:
        storageClassName: prometheus
        resources:
          requests:
            storage: 10Gi
  retention: 10d
#以上部分用于关联storageclass
  serviceAccountName: prometheus-k8s
  serviceMonitorNamespaceSelector: {}
  serviceMonitorSelector: {}
  version: 2.34.0
```
5 验证  
查看prometheus组件,可以看到pod`prometheus-k8s-0`和`prometheus-k8s-1`已经成功运行了  
```
[root@node1 csi-driver-nfs]# kubectl get pod -n monitoring
NAME                                   READY   STATUS             RESTARTS   AGE
alertmanager-main-0                    2/2     Running            0          24h
alertmanager-main-1                    2/2     Running            0          24h
alertmanager-main-2                    2/2     Running            0          24h
blackbox-exporter-676d976865-fg5bg     3/3     Running            0          24h
grafana-55b8fff56-vm29g                1/1     Running            0          24h
kube-state-metrics-5d6885d89-n4922     2/3     Running            0          24h
node-exporter-9s4tr                    2/2     Running            0          24h
node-exporter-gn5lq                    2/2     Running            0          24h
node-exporter-j2f7g                    2/2     Running            0          24h
node-exporter-qjlxb                    2/2     Running            0          24h
node-exporter-t2ddx                    2/2     Running            0          24h
prometheus-adapter-6cf5d8bfcf-98zjd    1/1     Running            0          24h
prometheus-adapter-6cf5d8bfcf-dd6ls    1/1     Running            0          24h
prometheus-k8s-0                       2/2     Running            0          53m
prometheus-k8s-1                       2/2     Running            0          53m
prometheus-operator-7f58778b57-f67hp   2/2     Running            7          24h
```
对应的数据文件放在了pod`nfs-server-56dfcc48c8-zcfj4`所在节点的`/nfs/vol`目录下

```
[root@node1 csi-driver-nfs]# kubectl get pod -o wide
NAME                          READY   STATUS    RESTARTS   AGE    IP              NODE    NOMINATED NODE   READINESS GATES
nfs-server-56dfcc48c8-zcfj4   1/1     Running   0          114m   10.244.10.79    node4   <none>           <none>
nginx-nfs-example             1/1     Running   0          72m    10.244.33.141   node5   <none>           <none>

[root@node4 ~]# ll /nfs-vol/
total 0
drwxrwxrwx. 3 root root 27 Mar 26 14:48 pvc-4adea28f-b510-4d62-9589-3a3e95cd5c1b
drwxrwxrwx. 3 root root 27 Mar 26 14:36 pvc-a4eaaa48-9fd2-4915-8321-fb2e6b78daee

[root@node4 ~]# tree /nfs-vol/
/nfs-vol/
├── pvc-4adea28f-b510-4d62-9589-3a3e95cd5c1b
│   └── prometheus-db
│       ├── chunks_head
│       ├── lock
│       ├── queries.active
│       └── wal
│           └── 00000000
└── pvc-a4eaaa48-9fd2-4915-8321-fb2e6b78daee
    └── prometheus-db
        ├── chunks_head
        ├── lock
        ├── queries.active
        └── wal
            └── 00000000

8 directories, 6 files

```

### 遇见的问题  
在storageclass.yaml文件中注释了`nconnect=8` 解释如下：
Linux 有一个名为“nconnect”的新功能，它可以为单个 NFS 挂载启用多个 TCP 连接。将 nconnect 设置为挂载选项可使 NFS 客户端为同一主机打开多个“传输连接”。
nconnect 包含在linux 内核版本 >= 5.3中。（所以它在使用 Linux 内核 5.4 的 Ubuntu 20.04 中可用）。
当前 nconnect 打开的客户端-服务器连接数限制为8
如果开启会报错`failed: exit status 32`  [如图](https://s2.loli.net/2022/03/26/XVp76gaxvbRP2rJ.png)

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
