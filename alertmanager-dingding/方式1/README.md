### **方式1：**
- 使用prometheus-webhook-dingtalk:v0.3.0镜像,端口是8060
  - 使用此镜像自带模板来实现告警
- 以下操作都在prometheus-operator的**manifests**目录下进行
下载deployment文件并创建
```
wget xxxxxxx
kubectl create -f dingtalk.yaml
```
#### 配置alertmanager
vim alertmanager.yaml
```
global:
  resolve_timeout: 1m
route:
  group_by: ['job', 'severity']
  group_wait: 30s
  group_interval: 1m 
  repeat_interval: 1m
  receiver: 'webhook'
  routes:
  - receiver: webhook
    group_wait: 30s
    match:
      severity: none
  - receiver: webhook
    match_re:
      severity: none|warning|critical
receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://dingtalk-hook:8060/dingtalk/default/send'
    send_resolved: true
```
先删除prometheus-operator自带的告警,再创建自定义的告警
```
kubectl delete secret alertmanager-main -n monitoring
kubectl create secret generic alertmanager-main --from-file=alertmanager.yaml -n monitoring
```
[钉钉告警展示](https://i.loli.net/2019/12/03/1kGU8hams3tSX6O.jpg) \
[钉钉告警展示](https://i.loli.net/2019/12/03/J1OVICvxZ2NeSPm.png) 
#### 删除默认自带的告警
- 不能直接改cm需要改crd
```
kubectl get crd -n monitoring
kubectl get prometheusrules -n monitoring
kubectl edit prometheusrules prometheus-k8s-rules -n monitoring
```
#### alertmanager配置解析
```
global:
  resolve_timeout: 1m #在没有报警的情况下申明已解决的时间
route: #所有的报警信息进入根路由，用来设置报警的分发策略
  group_by: ['job', 'severity'] #进行标签分组 好比有许多cluster=A和alertmanager=High这样的标签会被分配到一个分组内
  group_wait: 30s #分组完成后等待30秒
  group_interval: 1m #当第一个报警发送后，等待5分钟，来发送新一组的报警信息
  repeat_interval: 1m #一个报警信息在5分钟之内不会重复发送
  receiver: 'webhook' #默认的接收器receiver 如果报警信息没有被route匹配到，交由default来配置
  routes: #receiver接收器交由子路由来处理
  - receiver: webhook #接收方式
    group_wait: 30s
    match:
      severity: none #一个接收方式需要一个标签
  - receiver: webhook
    match_re: #匹配多个标签
      severity: none|warning|critical  #severity=none severity=warning
receivers: #接收器
- name: 'webhook' #处理方式和上面对应
  webhook_configs:
  - url: 'http://dingtalk-hook:8060/dingtalk/default/send' #使用svc方式 如果不是同一个ns，完整写法：http://dingtalk-hook.kube-ops.svc.cluster.local:5000
    send_resolved: true
```