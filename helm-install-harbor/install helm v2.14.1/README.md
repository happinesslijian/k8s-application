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
> 可能会花费些时间，如不成功多执行几次即可，最终如下图：
![微信截图_20190821180425.png](https://i.loli.net/2019/08/21/4RVWIMNYE9Zd2Cq.png)
- 接下来需要创建一个tiller的RBAC权限并更新其补丁
```
kubectl create -f RBAC.yaml
kubectl patch deploy --namespace kube-system tiller-deploy -p '{"spec":{"template":{"spec":{"serviceAccount":"tiller"}}}}'
```
