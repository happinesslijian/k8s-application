## 在 Kubernetes 上安装 OpenELB

#### OpenELB 是一个开源的云原生负载均衡器实现，可以在基于裸金属服务器、边缘以及虚拟化的 Kubernetes 环境中使用 LoadBalancer 类型的 Service 对外暴露服务。

#### 安装文档：  
[安装文档1](https://openelb.github.io/docs/getting-started/installation/install-openelb-on-kubernetes/)    
[安装文档2](https://mp.weixin.qq.com/s?__biz=MzU4MjQ0MTU4Ng==&mid=2247498293&idx=1&sn=a4d38c5ee263867450f18d1c97ffea72&chksm=fdbaf528cacd7c3eba1aafb093ef2e3fefba8030102ea589e5b1b7840fe3d1c37ea566a3dbf4&mpshare=1&scene=24&srcid=0410Z2O7k22O4eU2VzODhxph&sharer_sharetime=1649601660900&sharer_shareid=ab575ee248be46403d14707e78b85b1e#rd)  


#### 安装openelb
```
kubectl apply -f https://raw.githubusercontent.com/openelb/openelb/master/deploy/openelb.yaml
```

#### 首先需要为 kube-proxy 启用 strictARP，以便 Kubernetes 集群中的所有网卡停止响应其他网卡的 ARP 请求，而由 OpenELB 处理 ARP 请求。
```
kubectl edit configmap kube-proxy -n kube-system
......
ipvs:
  strictARP: true
......
```
#### 重启kube-proxy
```
kubectl rollout restart daemonset kube-proxy -n kube-system
```


#### 编辑eip.yaml
```
apiVersion: network.kubesphere.io/v1alpha2
kind: Eip
metadata:
  name: eip-pool
spec:
  address: 10.121.141.118-10.121.141.119  #IP地址段
  protocol: layer2  #openelb模式
  disable: false    #表示是否禁用 Eip 对象
  interface: eth0   #本地网卡
```

#### 验证：
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: nginx
  annotations:
    lb.kubesphere.io/v1alpha1: openelb    #指定该 Service 使用 OpenELB
    protocol.openelb.kubesphere.io/v1alpha1: layer2    #指定 OpenELB 用于 Layer2 模式
    eip.openelb.kubesphere.io/v1alpha2: eip-pool    #指定了 OpenELB 使用的 Eip 对象
spec:
  selector:
    app: nginx
  type: LoadBalancer
  ports:
    - name: http
      port: 80
      targetPort: 80

```
#### 网页访问`10.121.141.118`即可
```
[root@node1 openelb]# kubectl get svc
NAME             TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)                         AGE
kubernetes       ClusterIP      10.244.64.1     <none>           443/TCP                         17d
nfs-server       ClusterIP      10.244.79.6     <none>           2049/TCP,111/UDP                16d
nginx            LoadBalancer   10.244.80.166   10.121.141.118   80:32760/TCP                    20m
vault            NodePort       10.244.78.96    <none>           8200:32000/TCP,8201:30904/TCP   4d
vault-internal   ClusterIP      None            <none>           8200/TCP,8201/TCP               4d
```