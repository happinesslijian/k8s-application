# kubernetes升级记录
**说明：** 这里使用的是kubeadm安装的kubernetes，不是**二进制安装**！升级只可逐步升级，不可夸大版本升级！

环境说明：

|当前集群版本|欲升级版本|
|:--:|:--:|
|v1.15.1|v1.15.2|

1. 查看kubeadm配置文件
```
kubeadm config view
```
2. 把上面打印出来的信息复制粘贴到kubeadm-config.yaml中（将上面的imageRepository值更改为：`gcr.azk8s.cn/google_containers`）\
[如图所示](https://i.loli.net/2019/09/10/Wg8hB5fpDkcjbix.png)

3. 这里指定你要升级的版本注意：不能夸版本升级
```
yum makecache fast && yum -y install kubeadm-1.15.2 kubectl-1.15.2
```
- 执行``kubeadm version``进行查看 \
[如图所示](https://i.loli.net/2019/09/12/Jrd1alqR4P3psQK.png)

4. 执行如下命令查看是否可以升级
```
kubeadm upgrade plan
```
[如图所示](https://i.loli.net/2020/01/08/6SZmvkwcHRLg1x9.png)
- 尝试升级 **说明：** 即使这里失败了，也不会影响正常集群运行,在输出最后看到successfully即可
```
kubeadm upgrade apply v1.15.2 --config kubeadm-config.yaml --dry-run
```
5. 正式升级，执行如下命令
```
kubeadm upgrade apply v1.15.2 --config kubeadm-config.yaml
```
6. 执行```kubectl version```查看kubectl信息

[如图所示](https://i.loli.net/2019/09/10/jMkT98YBe7pXlKP.png)

7. 在master节点执行```kubectl get nodes```看到VERSION还是老版本
- 在老版本机器上执行
```
yum -y install kubelet-1.15.2
```
8. 执行如下命令(每个节点都要执行)
```
systemctl daemon-reload && systemctl restart kubelet
```
9. 在master节点执行```kubectl get nodes```查看VERSION版本

[完成升级](https://i.loli.net/2019/09/10/KcC3modNzJQ9B6q.png)

10. [查看证书](https://i.loli.net/2019/09/11/3pvWmrljuqQib58.png) 
默认是1年的期限，当升级完成之后，会自动刷新证书时间
```
kubeadm alpha certs check-expiration
```
# 问题说明：
有的同学可能使用的是ansible脚本来安装的kubeadm，每个ansible脚本是不一样的，比如有的默认把``mirrirs.aliyun.com``关闭了，那这里需要在升级一开始之前就开启，在升级后再将其关闭如下：
```
yum-config-manager --enable kubernetes #开启
yum-config-manager --disable kubernetes #关闭
```
