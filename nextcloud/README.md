# helm部署nextcloud
### 说明：使用[helm](https://github.com/happinesslijian/k8s-application/tree/master/helm-install-harbor/install%20helm%20v2.14.1)安装,提前准备一个[storageclass](https://github.com/happinesslijian/k8s-application/tree/master/nfs)
安装nextcloud服务
```
$kubectl create ns nextcloud
$helm fetch --untar stable/nextcloud
$cd nextcloud
$wget https://raw.githubusercontent.com/happinesslijian/k8s-application/master/nextcloud/helm-values.yaml
$helm install --name nextcloud -f helm-values.yaml . --namespace=nextcloud
$kubectl get pod,svc -n nextcloud
NAME                             READY   STATUS    RESTARTS   AGE
pod/nextcloud-7d8d66ddb8-prlnd   1/1     Running   0          83s
pod/nextcloud-mariadb-0          1/1     Running   0          83s

NAME                        TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
service/nextcloud           NodePort    10.244.110.157   <none>        8080:30950/TCP   83s
service/nextcloud-mariadb   ClusterIP   10.244.115.86    <none>        3306/TCP         84s
```
查看日志(初始化速度会很慢)
```
$kubectl logs -f nextcloud-7d8d66ddb8-prlnd -n nextcloud
Initializing nextcloud 16.0.3.0 ...
Initializing finished
New nextcloud instance
Installing with MySQL database
starting nextcloud installation
Nextcloud was successfully installed
setting trusted domains…
System config value trusted_domains => 1 set to string nextcloud.test.com
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.244.2.25. Set the 'ServerName' directive globally to suppress this message
AH00558: apache2: Could not reliably determine the server's fully qualified domain name, using 10.244.2.25. Set the 'ServerName' directive globally to suppress this message
[Fri Oct 25 10:46:50.936961 2019] [mpm_prefork:notice] [pid 1] AH00163: Apache/2.4.38 (Debian) PHP/7.3.8 configured -- resuming normal operations
···
···
```
验证 浏览器输入`domain name:port` \
[如图所示](https://i.loli.net/2019/10/25/PMFjqNWts6TaBpQ.png)

## 问题处理：
[如图所示](https://i.loli.net/2019/10/25/21sL8XkU9nD6j4Q.png)

- 更改持久化目录`config/config.php`
  - 我这里使用的是nfs持久化存储
```
vim /data/k8s/nextcloud-nextcloud-nextcloud-pvc-17639bad-12f6-4611-b21a-f0dbdf21892a/config/config.php

### 在后面把端口写上
### 记得在windows机器上配置hosts
···
array (
  0 => 'localhost',
  1 => 'nextcloud.test.com:30950',
),
···
```
- [接入openldap](https://github.com/happinesslijian/k8s-application/tree/master/ldap#%E6%8E%A5%E5%85%A5%E5%BA%94%E7%94%A8%E8%AE%BE%E7%BD%AE)
