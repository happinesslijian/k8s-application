# 搭建私人博客
- 下载mysql和solo文件
  - 文件中使用了nodeName跳过了kubeSchedule,指定其运行在k8s-node2上.
```
wget && wget
```
- 安装mysql和solo
```
#替换spec.template.spec.containers.args中的--server_host=domainName

kubectl create -f mysql.yaml

#查看mysql的ClusterIP并复制到solo.yaml文件spec.template.spec.containers.env.name: JDBC_URL中

kubectl get pod,svc -n solo

#更改完成之后,安装solo

kubectl create -f solo.yaml
```
- 验证
  - web页面访问
    `http://domainName:port`
  - 使用github账号登录即可