# 安装nextcloud
简介：nextcloud分为前端nextcloud-apache，后端mariadb数据库。我这里把Apache和mariadb都安装在nextcloud命名空间。我这里使用的持久化存储是nfs详情见pvc.yaml \
**注意：/data/k8s/是我nfs默认的挂载目录,在这里,我把nfs持久化目录改为/data/k8s/nextcloud-mariadb/也就是说,持久化的数据会写在/data/k8s/nextcloud-mariadb/里,而不是/data/k8s/目录下。如果指定/data/k8s/来做持久化目录,那么原本在/data/k8s/目录下的持久化存储目录都会被覆盖！造成数据丢失！所以,这里还需去到nfs服务器的/data/k8s/目录下创建一个名为nextcloud-mariadb的目录！后面的nextcloud也是一样,需要手动创建一个名为nextcloud的目录！**
```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: mariadb-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/k8s/nextcloud-mariadb/
    server: 192.168.100.158
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mariadb-pvc
  namespace: nextcloud
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
```
- 安装后端mariadb数据库
```
cd k8s-application/nextcloud/nextcloud-yaml/mariadb
#创建命名空间
kubectl create -f namespace.yaml
#创建mariadb数据库
kubectl create -f deployment.yaml
#创建mariadb数据库服务
kubectl create -f service.yaml
#根据实际情况修改pvc.yaml
kubectl create -f pvc.yaml
#根据实际情况修改secret
kubectl create -f secret.yaml
```
查看创建进度
```
$kubectl get pod,svc -n nextcloud
NAME                          READY   STATUS    RESTARTS   AGE
pod/mariadb-6d6897656-m6wgd   1/1     Running   0          54s

NAME              TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)    AGE
service/mariadb   ClusterIP   10.244.84.136   <none>        3306/TCP   48s
```
- 安装前端apache-nextcloud
```
cd k8s-application/nextcloud/nextcloud-yaml/apache-nextcloud
#创建apache-nextcloud应用
kubectl create -f deployment.yaml
#创建apache-nextcloud服务
kubectl create -f service.yaml
#根据实际情况修改pvc.yaml
kubectl create -f pvc.yaml
```
查看创建进度
```
$kubectl get pod,svc -n nextcloud
NAME                             READY   STATUS    RESTARTS   AGE
pod/mariadb-6d6897656-m6wgd      1/1     Running   0          5m46s
pod/nextcloud-68ffcb45c8-fh2ll   1/1     Running   0          3m46s

NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
service/mariadb     ClusterIP   10.244.84.136   <none>        3306/TCP       5m40s
service/nextcloud   NodePort    10.244.92.241   <none>        80:30781/TCP   3m42s
```
- 查看日志
  - 这里速度很慢,直到有日志输出后再去验证
```
$kubectl logs -f nextcloud-68ffcb45c8-fh2ll -n nextcloud
Initializing nextcloud 17.0.0.9 ...
Initializing finished
New nextcloud instance
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.244.2.43. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.244.2.43. Set the 'ServerName' directive globally to suppress this message
[Sun Oct 27 03:36:38.732180 2019] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.3.11 configured -- resuming normal operations
[Sun Oct 27 03:36:38.732460 2019] [core:notice] [pid 1] AH00094: Command line: 'apache2 -D FOREGROUND'
```
- 验证
  - 创建用户名密码即可
[如图所示](https://i.loli.net/2019/10/27/OzbaAgBviLMGZUf.png)

[问题处理](https://github.com/happinesslijian/k8s-application/tree/master/nextcloud#%E9%97%AE%E9%A2%98%E5%A4%84%E7%90%86)


新创建的用户目录：
`/data/k8s/nextcloud/data/`

用户文件目录：
`/data/k8s/nextcloud/data/$user/files/`

## 关于HorizontalPodAutoscaler问题说明
有时候创建完HPA后发现其状态都是unknown，解决办法在其对应的控制器下containers.下面添加`resources`和`requests`
```
      containers:
        - image: nextcloud:apache
          ···
          resources:
            limits:
              cpu: 2000m
              memory: 2Gi
            requests:
              cpu: 1000m
              memory: 1000Mi
```
