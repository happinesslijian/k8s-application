# prometheus-operator使用cephfs做持久化
**问题描述：**
使用cephfs来做k8s prometheus-operator的持久化存储默认没有读写的权限
日志提示："opening storage failed: create dir: mkdir /prometheus/wal: permission denied"

**说明：**
这里使用的是cephfs来做后端持久化存储，如果是nfs来做后端持久化存储不需要改动相关权限等
- prometheus-operator安装
```
git clone https://github.com/coreos/kube-prometheus.git
```
[安装完成如图](https://i.loli.net/2019/09/09/zM7AfpxFEWyDoKP.png)
- 因为现在是没有持久化的，所以要更改一下`prometheus-prometheus.yaml`文件
```
vi prometheus-prometheus.yaml
```
[更改前如图](https://i.loli.net/2019/09/09/Nvof6OAnRyirE8h.png) \
[更改后如图](https://i.loli.net/2019/09/09/3t7NZzQPpE5s1u4.png) \
更改完成后更新prometheus-prometheus.yaml文件即可
