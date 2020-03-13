# 在k8s中部署zabbix-server
### 背景：最近迷恋上helm,但是对helm特别陌生,写这篇文章的时候主要是想学习一下helm的使用方式,因此，我在这里使用helm部署了一个zabbix-server和postgresql数据库
## 整体思路:
- 使用helm部署zabbix-server
- 使用helm部署postgresql
- 部署zabbix-agent
### 步骤一： 先决条件准备
- Kubernetes集群1.10+
- helm3.0+
- 基础架构中的PV供应商支持
---
- 安装nfs(当然也可以是其他持久化存储 如ceph 这里使用nfs)

`nfs服务端192.168.100.158`操作

1.安关闭防火墙 \
`systemctl stop firewalld` \
`systemctl disable firewalld` \
2.安装配置nfs \
`yum -y install nfs-utils rpcbind` \
3. 创建共享目录分配权限 \
`mkdir -p /data/k8s/` \
`vi /etc/exports`
> /data/k8s  *(rw,sync,no_root_squash) 

先启动rpcbind
```
systemctl start rpcbind
systemctl enable rpcbind
systemctl status rpcbind
```
再启动nfs
```
systemctl start nfs
systemctl enable nfs
systemctl status nfs
```
通过命令确认
`rpcinfo -p|grep nfs`
- 安装helm3 

(helm3有开箱即用的特性,只要放在`$PATH`路径下即可使用)过程略

- 使用helm部署后端是nfs存储的`StorageClass`
```
# 添加helm的repo源
helm repo add stable https://kubernetes-charts.storage.googleapis.com

# 把repo源中的nfs  pull到本地编辑values.yaml文件

helm pull stable/nfs-client-provisioner --untar

# values.yaml文件如下：(按照你的环境改改就可以使用)

配置文件下载 https://nextcloud.k8s.fit/s/QwPsdxp26RzwLYa

# 文件准备完毕接下来安装

helm install nfs -f values.yaml stable/nfs-client-provisioner

# 安装完成后有可能pull不下来image,手动编辑nfs的控制器把image的TAG改为latest即可

[root@k8s-master zabbix]# kubectl get pod,sc
NAME                                            READY   STATUS    RESTARTS   AGE
pod/nfs-nfs-client-provisioner-9b7476bd-6lwcq   1/1     Running   0          5h51m

NAME                                 PROVISIONER                                AGE
storageclass.storage.k8s.io/zabbix   cluster.local/nfs-nfs-client-provisioner   5h52m
```
### 步骤二：部署zabbix-server和postgresql数据库
```
# 添加repo源
helm repo add cetic https://cetic.github.io/helm-charts

把repo源中的zabbix  pull到本地编辑values.yaml文件

helm pull cetic/zabbix --untar

# values.yaml文件如下：(按照你的环境改改就可以使用)

配置文件下载 https://nextcloud.k8s.fit/s/QwPsdxp26RzwLYa
```
```
# 修改子chart的values.yaml文件：(按照你的环境改改就可以使用)
cd charts/postgresql/

配置文件下载 https://nextcloud.k8s.fit/s/QwPsdxp26RzwLYa
```
### 步骤三：安装zabbix-server和postgresql数据库
```
[root@k8s-master zabbix]# helm install zabbix -f values.yaml ./

# 到这里zabbix-server和postgresql数据库就安装完成了

[root@k8s-master zabbix]# kubectl get pod,svc
NAME                                            READY   STATUS    RESTARTS   AGE
pod/ldap-ldap-self-service-67c5c77db4-kjhrt     1/1     Running   0          24h
pod/nfs-nfs-client-provisioner-9b7476bd-6lwcq   1/1     Running   0          6h13m
pod/zabbix-0                                    2/2     Running   0          137m
pod/zabbix-postgresql-0                         1/1     Running   0          137m
pod/zabbix-web-77dd64df-j56jp                   1/1     Running   2          137m

NAME                                 TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)                           AGE
service/kubernetes                   ClusterIP   10.244.64.1      <none>        443/TCP                           9d
service/zabbix-agent                 ClusterIP   10.244.112.174   <none>        10050/TCP                         137m
service/zabbix-postgresql            ClusterIP   10.244.111.118   <none>        5432/TCP                          137m
service/zabbix-postgresql-headless   ClusterIP   None             <none>        5432/TCP                          137m
service/zabbix-server                NodePort    10.244.95.121    <none>        10051:30314/TCP,10052:32198/TCP   137m
service/zabbix-web                   NodePort    10.244.114.114   <none>        80:31956/TCP                      137m

# 注意要把service/zabbix-server的type换成NodePort,最好是一个固定的端口(这一步是在为zabbix-agent做准备)
```
### 步骤四：安装zabbix-agent
>说明：我之前在这里也很懵,不知道该怎么去实现监控,经过这一次踩坑,我总结如下：
监控node节点：此时zabbix-server已经部署在k8s里了,可以通过ds控制器来部署zabbix-agent来监控各个node节点。
监控虚拟机：可以使用docker跑一个zabbix-agent来完成监控,或者直接yum install zabbix-agent
我这里选择直接yum安装了
```
# 被监控机器操作

yum -y install http://repo.zabbix.com/zabbix/4.2/rhel/7/x86_64/zabbix-release-4.2-1.el7.noarch.rpm

yum -y install zabbix-agent
```
- 修改配置文件
```
vim /etc/zabbix/zabbix_agentd.conf

# 这里只改3个地方

Server=192.168.100.150
ServerActive=192.168.100.150:30314
Hostname=ansible1

systemctl restart zabbix-agent
```
接下来回到zabbix图形化界面配置好被监控的机器就可以看到监控图了。
### 总结：
这篇文章写得比较潦草,没有过多讲解,更多的需要自己去研究配置文件。上面这种方式只是把zabbix-server和postgresql数据库进行容器化了,而zabbix-agent我选择的还是yum方式直接安装的,当然你可以使用docker跑一个zabbix-agent