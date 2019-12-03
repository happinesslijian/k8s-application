### **方式3：**
- 使用prometheus-webhook-dingtalk:v0.3.0镜像来完成告警
  - 说明：不使用此镜像自带模板,我们来自定义模板
  - 以下操作都在prometheus-operator的**manifests**目录下进行
- 定义告警模板

vim global-tmpl.yaml
```
apiVersion: v1
data:
  dingding.tmpl: >-
    {{ define "__subject" }}[{{ .Status | toUpper }}[{{ if eq .Status "firing"
    }}告警:{{ .Alerts.Firing | len }}{{ else }}恢复{{ end }}] {{
    .GroupLabels.SortedPairs.Values | join " " }} {{ if gt (len .CommonLabels)
    (len .GroupLabels) }}({{ with .CommonLabels.Remove .GroupLabels.Names }}{{
    .Values | join " " }}{{ end }}){{ end }}{{ end }}

    {{ define "__alertmanagerURL" }}{{ .ExternalURL }}/#/alerts?receiver={{
    .Receiver }}{{ end }}


    {{ define "__text_alert_list" }}

    {{ if eq .Status "firing" }}

    {{ range .Alerts.Firing }}

    **Labels**

    {{ range .Labels.SortedPairs }}

    {{ if eq .Name "cluster"}}Cluster: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "namespace"}}Namespace: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "deployment"}}App_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "container_name"}}contain_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "pod"}}pod_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "daemonset"}}daemonset_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "statefulset"}}statefulset_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "severity"}}Severity: {{ .Value|markdown|html }}{{ end }}

    {{ end }}

    **Annotations**

    {{ range .Annotations.SortedPairs }}

    {{ if eq .Name "description"}}description: {{ .Value|markdown|html }}{{ end }}
    {{ if eq .Name "message"}}description: {{ .Value|markdown|html }}{{ end }}

    {{ end }}{{ end }}


    {{ else if eq .Status "resolved" }}

    {{ range .Alerts.Resolved }}

    **Labels**

    {{ range .Labels.SortedPairs }}

    {{ if eq .Name "cluster"}}Cluster: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "namespace"}}Namespace: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "deployment"}}App_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "container_name"}}contain_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "pod"}}pod_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "daemonset"}}daemonset_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "statefulset"}}statefulset_name: {{ .Value|markdown|html }}{{ end }}

    {{ if eq .Name "severity"}}Severity: {{ .Value|markdown|html }}{{ end }}

    {{ end }}

    **Annotations**

    {{ range .Annotations.SortedPairs }}

    {{ if eq .Name "description"}}description: {{ .Value|markdown|html }}{{ end }}
    {{ if eq .Name "message"}}description: {{ .Value|markdown|html }}{{ end }}

    {{ end }}

    {{ end }}

    {{ end }}

    {{ end }}



    {{ define "ding.link.title" }}{{ template "__subject" . }}{{ end }}

    {{ define "ding.link.content" }}#### [{{ if eq .Status "firing" }}告警:{{
    .Alerts.Firing | len }}{{ else }}恢复:{{ end }}] **{{ index .GroupLabels
    "alertname" }}**

    {{ template "__text_alert_list" . }}

    {{ end }}
kind: ConfigMap
apiVersion: v1
metadata:
  name: dingding
  namespace: monitoring
```
## 创建告警发送器
- 这里使用的是prometheus-webhook-dingtalk:v0.3.0,端口是8060
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
        image: timonwong/prometheus-webhook-dingtalk:v0.3.0
        args:
          - '--web.listen-address=0.0.0.0:8060'
          - '--ding.profile=default=https://oapi.dingtalk.com/robot/send?access_token=10bda98979ae2155b6822b699cde1841d4fbd8514c0441bbbb4485caddf3a388x' 
          - '--log.level=info'
          - '--template.file=/etc/template/dingding.tmpl'
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
          - mountPath: /etc/template/
            name: dingtalk-hook
      volumes:
        - configMap:
            defaultMode: 420
            name: dingding
          name: dingtalk-hook
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
## 创建接收方式
vim alertmanager.yaml
```
global:
  resolve_timeout: 1m
  smtp_smarthost: 'smtp.163.com:25'
  smtp_from: 'xxx@163.com'
  smtp_auth_username: 'xxx@163.com'
  smtp_auth_password: 'passwd'
  smtp_hello: '163.com'
  smtp_require_tls: false
route:
  group_by: ['job', 'severity']
  group_wait: 30s
  group_interval: 1m
  repeat_interval: 1m
  receiver: default
  routes:
  - receiver: webhook
    match:
      severity: none
  - receiver: webhook
    match_re:
      severity: none|warning|critical
  - receiver: email
    group_wait: 30s
    match:
      severity: warning
receivers:
- name: 'default'
  email_configs:
  - to: 'lijian_bj@xxxx.com.cn'
    send_resolved: true
- name: 'email'
  email_configs:
  - to: 'lijian_bj@xxxx.com.cn'
    send_resolved: true    
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
#### 删除默认自带的告警
- 不能直接改cm需要改crd
```
kubectl get crd -n monitoring
kubectl get prometheusrules -n monitoring
kubectl edit prometheusrules prometheus-k8s-rules -n monitoring
```
注意：方法三有个小瑕疵,有的可以正常显示,有的匹配不到alertname,至今没找到问题所在

[如图所示](https://i.loli.net/2019/12/03/DnKCWOIgoMqpTVA.png)