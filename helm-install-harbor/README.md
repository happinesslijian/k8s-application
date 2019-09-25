## harbor in k8s for nfs to StorageClass
注：这里使用helm v2版本的helm进行部署harbor 
- [install helm v2.14.1](https://github.com/happinesslijian/k8s-application/tree/master/helm-install-harbor/install%20helm%20v2.14.1)
- [install nfs StorageClass](https://github.com/happinesslijian/k8s-application/tree/master/nfs)
### 克隆官方chart
```
git clone https://github.com/goharbor/harbor-helm
cd harbor-helm
git checkout 1.0.0
cp $https://github.com/happinesslijian/helm-install-harbor/harbor.values.yaml ./
kubectl create ns harbor
helm install --name harbor -f harbor-values.yaml . --namespace harbor
```
### 问题处理：
+ 安装完成之后你会发现core组件起不来,日志如下图所示 \
[如图所示](https://i.loli.net/2019/09/16/RVsJxne7WZzu3dH.png) \
解决方案如下：
```
kubectl exec -it harbor-harbor-database-0 -n harbor /bin/bash
psql --username postgres  #使用postgres登录
CREATE DATABASE registry ENCODING 'UTF8';  #创建registry数据库
\c registry;  #切换数据库
\l  #查看数据库
\dt  #查看表
update public.schema_migrations set dirty = false;  #schema_migrations表里面dirty字段改为false
```
[如图所示](https://i.loli.net/2019/09/16/ExtRy4JbQA2fcqW.png)
- 重启core pod即可 \
kubectl delete pod xxx -n harbor

