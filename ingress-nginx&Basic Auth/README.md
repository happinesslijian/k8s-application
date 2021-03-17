# 安装ingress-nginx&Basic Auth认证
## install ingress-nginx
- 安装ingress-nginx,开启hostPort端口,用于转发访问请求
```
$ kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml
$ kubectl edit deploy nginx-ingress-controller -n ingress-nginx
        ports:
        - containerPort: 80
          hostPort: 80 #开启到宿主机的端口
          name: http
          protocol: TCP
        - containerPort: 443
          hostPort: 443 #开启到宿主机的端口
```
- 查看是否正常运行
```
$ kubectl get pod -n ingress-nginx
NAME                                      READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-799dbf6fbd-vmrkg   1/1     Running   0          37s
```
## Basic Auth 认证 example:prometheus
- 创建存储用户名密码的htpasswd文件
```
$ yum -y install httpd
$ htpasswd -bc auth admin admin123
$ kubectl create secret generic prometheus-auth --from-file=auth -n monitoring
secret/prometheus-auth created
```
- 使用https进行访问
  - 我这里是创建自定义证书
```
$ openssl genrsa -out tls.key 2048
$ openssl req -new -x509 -days 365 -key tls.key -out tls.crt -subj /C=CN/ST=Beijingshi/L=Beijing/O=devops/CN=cn
## 查看openssl自创证书有效期
$ openssl x509 -in tls.crt -noout -dates
$ kubectl create secret tls prometheus-https --cert=tls.crt --key=tls.key -n monitoring
secret/prometheus-https created
```
- 创建prometheus-ingress.yaml文件
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-prometheus
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: prometheus-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - admin'
spec:
  tls:
  - hosts:
    - test.promethues.com
    secretName: prometheus-https
  rules:
  - host: test.prometheus.com
    http:
      paths:
      - path:
        backend:
          serviceName: prometheus-k8s
          servicePort: 9090
```
- 创建prometheus-ingress.yaml文件
```
kubectl apply -f prometheus-ingress.yaml
```
[如图所示](https://i.loli.net/2019/10/15/GZ4Vu1WDvAbqo3O.png)
## Basic Auth 认证 example:alertmanager
- 创建存储用户名密码的htpasswd文件
```
$ yum -y install httpd
$ htpasswd -bc auth admin admin123
$ kubectl create secret generic alertmanager-auth --from-file=auth -n monitoring
secret/alertmanager-auth created
```
- 使用https进行访问
  - 我这里是创建自定义证书
```
$ openssl genrsa -out tls.key 2048
$ openssl req -new -x509 -days 365 -key tls.key -out tls.crt -subj /C=CN/ST=Beijingshi/L=Beijing/O=devops/CN=cn
$ kubectl create secret tls alertmanager-https --cert=tls.crt --key=tls.key -n monitoring
secret/alertmanager-https created
```
- 创建alertmanager-ingress.yaml文件
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-alertmanager
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: alertmanager-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - admin'
spec:
  tls:
  - hosts:
    - test.alertmanager.com
    secretName: alertmanager-https
  rules:
  - host: test.alertmanager.com
    http:
      paths:
      - path:
        backend:
          serviceName: alertmanager-main
          servicePort: 9093
```
- 创建prometheus-ingress.yaml文件
```
kubectl apply -f alertmanager-ingress.yaml
```
[如图所示](https://s2.ax1x.com/2019/10/15/K94740.png)

# 对应参数详解
```
apiVersion: extensions/v1beta1
kind: Ingress #资源对象ingress
metadata:
  name: ingress-prometheus #定义名称
  namespace: monitoring #ingress的命名空间一定要和服务在同一个命名空间下面
  annotations:
    kubernetes.io/ingress.class: "nginx"  #指定这个ingress资源对象通过ingress-nginx来处理
    nginx.ingress.kubernetes.io/auth-type: basic #指定使用哪种认证方式
    nginx.ingress.kubernetes.io/auth-secret: prometheus-auth #使用htpasswd -bc auth admin admin123创建出来的令牌被secret包含起来
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - admin' #当认证的时候显示一个合适的上下文信息
spec:
  tls: #配置证书openssl genrsa -out tls.key 2048 #openssl req -new -x509 -days 365 -key tls.key -out tls.crt -subj /C=CN/ST=Beijingshi/L=Beijing/O=devops/CN=cn
  - hosts:
    - test.prometheus.com #自定义域名
    secretName: ingress-nginx-cert #定义名字要和服务在同一个命名空间下面 kubectl create secret tls ingress-nginx-cert --cert=tls.crt --key=tls.key -n default
  rules:
  - host: test.prometheus.com #自定义域名
    http:
      paths:
      - path: 
        backend:
          serviceName: prometheus-k8s #服务的service名字
          servicePort: 9090 #端口
``` 
# 整合到一起
- prometheus-operator部署完成之后只有prometheus和alertmanager和grafana三个组件需要开启dashboard,下面我们把上述三个组件的ingress整合到一起
- 创建ingress.yaml
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress
  namespace: monitoring
  annotations:
    kubernetes.io/ingress.class: "nginx"
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: prometheus-auth
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - admin'
spec:
  tls:
  - hosts:
    - k8s.promethues.com
    secretName: prometheus-https
  rules:
  - host: k8s.prometheus.com
    http:
      paths:
      - path:
        backend:
          serviceName: prometheus-k8s
          servicePort: 9090
  - host: k8s.alertmanager.com
    http:
      paths:
      - path:
        backend:
          serviceName: alertmanager-main
          servicePort: 9093
  - host: k8s.grafana.com
    http:
      paths:
      - path:
        backend:
          serviceName: grafana
          servicePort: 3000
```
