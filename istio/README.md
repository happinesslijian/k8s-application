# 安装istio-1.3.0
### 说明：这里使用的是[helm](https://github.com/happinesslijian/k8s-application/tree/master/helm-install-harbor/install%20helm%20v2.14.1)安装的istio-1.3.0
- [安装helm](https://github.com/happinesslijian/k8s-application/tree/master/helm-install-harbor/install%20helm%20v2.14.1)
- 下载并解压istio-1.3.0
```
https://github.com/istio/istio/releases/download/1.3.0/istio-1.3.0-linux.tar.gz
tar xf istio-1.3.0-linux.tar.gz
cd istio-1.3.0
```
- 开启默认未开启的组件
```
cat <<EOF> istio.yaml
tracing:
  enabled: true
servicegraph:
  enabled: true
kiali:
  enabled: true
grafana:
  enabled: true
EOF
```
- 创建命名空间
```
kubectl create ns istio-system
```
- 可执行文件拷贝到`$PATH`目录
```
cp bin/istioctl /usr/local/bin/
istioctl version
```
- 安装istio-init图表以引导所有Istio的CRD
```
helm install install/kubernetes/helm/istio-init --name istio-init --namespace istio-system
```
```
$ kubectl get crds | grep 'istio.io\|certmanager.k8s.io' | wc -l
23
```

- kiali仪表板的用户名和密码的密码
```
$ echo -n 'admin' | base64
YWRtaW4=
$ echo -n '123456' | base64
MTIzNDU2
$ cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: kiali
  namespace: istio-system
  labels:
    app: kiali
type: Opaque
data:
  username: YWRtaW4=
  passphrase: MTIzNDU2
EOF
```
- helm一键安装
```
helm install install/kubernetes/helm/istio --name istio --namespace istio-system -f istio.yaml
watch kubectl get pod -n istio-system
```
`完成安装后,默认SVC都是ClusterIP,手动把下面SVC换成NodePort即可打开web界面` \
**kiali** \
**jaeger-query** \
**grafana** \
**prometheus**
