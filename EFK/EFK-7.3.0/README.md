# EFK-7.3.0
## efk in k8s for nfs to storageclass
- 安装nfs-storageclass[传送门](https://github.com/happinesslijian/nfs)
---
```
创建logging命名空间
kubectl create ns logging
```
```
创建es
cd elasticsearch
kubectl create -f .
```
```
创建kibana 
cd kibana
kubectl create -f .
```
```
验证：查看其svc并登陆浏览器
kubectl get svc -n logging
http://IP:PORT
```
```
创建fluentd
cd fluentd
kubectl create -f .
```
```
添加日志源
logstash-*
```
