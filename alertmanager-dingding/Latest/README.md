#### 本篇文章不讲述如何使用prometheus监控容器,详细来说一下监控容器后续使用钉钉报警的讲解
---
#### 前言：
之前一直使用的是prometheus-webhook-dingtalk0.3.0版本来进行告警的

效果图如下:
![微信截图_20191210115820.png](https://i.loli.net/2019/12/10/SO6VsYziCwrtoav.png)
#### 作者关注了很久项目今天迎来了重大更新[Click me](https://github.com/timonwong/prometheus-webhook-dingtalk)迎来了prometheus-webhook-dingtalk1.2.2版本,整体有很大的革新,所以按奈不住躁动的心,前来尝试一番:

效果图如下: 

![微信截图_20191210115333.png](https://i.loli.net/2019/12/10/IOFB3sQ4Jcne6vb.png)
---
我使用的是prometheus-operator来部署的监控容器,这里不做过多赘述。
部署完成后效果图如下：
![微信截图_20191210120247.png](https://i.loli.net/2019/12/10/vGyAHaYRSVh612M.png)
可以看到已经都部署完成了,但是现在还没有关联钉钉告警,接下来我们来部署钉钉
1. 部署钉钉
  - 这里挂载了一个名为dingding的cm
```
vim dingtalk.yaml

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: dingtalk-hook
  namespace: monitoring
spec:
  template:
    metadata:
      labels:
        app: dingtalk-hook
    spec:
      containers:
      - name: dingtalk-hook
        image: timonwong/prometheus-webhook-dingtalk:v1.2.2
        args:
          - '--web.listen-address=0.0.0.0:8060'
          - '--log.level=info'
          - '--config.file=/etc/prometheus-webhook-dingtalk/config.yml'
        imagePullPolicy: IfNotPresent
        ports:
        - name: http
          containerPort: 8060
        resources:
          requests:
            cpu: 100m
            memory: 32Mi
          limits:
            cpu: 200m
            memory: 64Mi
        volumeMounts:
          - mountPath: /etc/prometheus-webhook-dingtalk/
            name: config-yml
      volumes:
        - configMap:
            defaultMode: 420
            name: dingding
          name: config-yml
---
apiVersion: v1
kind: Service
metadata:
  name: dingtalk-hook
  namespace: monitoring
spec:
  ports:
    - port: 8060
      protocol: TCP
      targetPort: 8060
      name: http
  selector:
    app: dingtalk-hook
  type: ClusterIP
```
2. 创建dingding  cm
```
vim prometheus-webhook-dingtalk-config.yaml

apiVersion: v1
data:
  config.yml: >-
    targets:
      webhook2:
        url: https://oapi.dingtalk.com/robot/send?access_token=10bda98979ae2155b6822b699cde1841d4fbd8514c0441bbbb4485caddf3a388x
      webhook_legacy:
        url: https://oapi.dingtalk.com/robot/send?access_token=10bda98979ae2155b6822b699cde1841d4fbd8514c0441bbbb4485caddf3a388x
        message:
          title: '{{ template "default.title" . }}'
          text: '{{ template "default.content" . }}'
      webhook_mention_all:
        url: https://oapi.dingtalk.com/robot/send?access_token=10bda98979ae2155b6822b699cde1841d4fbd8514c0441bbbb4485caddf3a388x
        mention:
          all: true
      webhook_mention_users:
        url: https://oapi.dingtalk.com/robot/send?access_token=10bda98979ae2155b6822b699cde1841d4fbd8514c0441bbbb4485caddf3a388x
        mention:
          mobiles: ['15xxxxxxxx0']
kind: ConfigMap
apiVersion: v1
metadata:
  name: dingding
  namespace: monitoring
```
3. 上面的两个文件编辑完成后进行创建
```
kubectl create -f dingtalk.yaml
kubectl create -f prometheus-webhook-dingtalk-config.yaml

kubectl get pod -n monitoring
#你会看到一个dingtalk-hook-xxxxx的pod状态已经是running
```
4. 钉钉也创建完成了配置文件也创建完成了,但是现在还没有和alertmanager进行关联,接下来把alertmanager和钉钉进行关联
```
# 配置alertmanager

vim alertmanager.yaml

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
    group_wait: 30s
    match_re:
      severity: none|warning|critical
receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://dingtalk-hook:8060/dingtalk/webhook2/send'
    send_resolved: true
```
  - 先删除prometheus-operator自带的告警,再创建自定义的告警
```
kubectl delete secret alertmanager-main -n monitoring
kubectl create secret generic alertmanager-main --from-file=alertmanager.yaml -n monitoring
```
#### 删除默认自带的告警
* 不能直接改cm需要改crd
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
# 注意事项：
- 每个告警规则的annotation下面都要增加一个description
- description是这个的关键字，否则显示不正常









