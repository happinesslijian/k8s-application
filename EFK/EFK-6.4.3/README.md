# EFK-6.4.3
## 说明：这里使用的是cephfs为后端持久化存储
### k8s-master内操作：
---
#### 创建rbac相关权限和namespace
```
cd rbac
kubectl create ns cephfs
kubectl create -f .
```
---
#### 创建logging命名空间
```
kubectl create ns logging
```
---
#### 创建es
```
cd elasticsearch
kubectl create -f .
```
------------
#### 创建kibana 
```
cd kibana
kubectl create -f .
```
------------
#### 验证：查看其svc并登陆浏览器
```
kubectl get svc -n logging
http://IP:PORT
```
---
#### 创建fluentd
```
cd fluentd
kubectl create -f .
```
---
#### 添加日志源
```
logstash-*
```
