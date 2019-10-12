# install helm-v2.14.1
- 下载包并解压并拷贝到/usr/local/bin/目录下并验证
```
wget https://get.helm.sh/helm-v2.14.1-linux-amd64.tar.gz
tar xf helm-v2.14.1-linux-amd64.tar.gz
cp linux-amd64/helm /usr/local/bin/
helm version
```
+ 默认是没有tiller的，这里需要初始化一下 \
`helm init --upgrade --tiller-image registry.cn-zhangjiakou.aliyuncs.com/lijianhappiness/helm:v2.14.1`
> 可能会花费些时间，如不成功多执行几次即可
- 接下来需要创建一个tiller的RBAC权限并更新其补丁
```
kubectl create -f RBAC.yaml
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```
- 验证helm版本
```
$ helm version
Client: &version.Version{SemVer:"v2.14.1", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.1", GitCommit:"5270352a09c7e8b6e8c9593002a73535276507c0", GitTreeState:"clean"}
```

# install helm-v2.14.2
- 下载包并解压并拷贝到/usr/local/bin/目录
```
wget https://get.helm.sh/helm-v2.14.2-linux-amd64.tar.gz
tar xf helm-v2.14.2-linux-amd64.tar.gz
mv linux-amd64/helm /usr/local/bin/
mv linux-amd64/tiller /usr/local/bin/
```
- 安装 Tiller 并为其配置 Service account
```
helm init --upgrade \
-i registry.cn-hangzhou.aliyuncs.com/google_containers/tiller:v2.14.2 \
--stable-repo-url https://kubernetes.oss-cn-hangzhou.aliyuncs.com/charts \
--service-account tiller
```
- 验证helm版本
```
$ helm version
Client: &version.Version{SemVer:"v2.14.2", GitCommit:"a8b13cc5ab6a7dbef0a58f5061bcc7c0c61598e7", GitTreeState:"clean"}
Server: &version.Version{SemVer:"v2.14.2", GitCommit:"a8b13cc5ab6a7dbef0a58f5061bcc7c0c61598e7", GitTreeState:"clean"}
```
