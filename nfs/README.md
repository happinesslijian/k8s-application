# [nfs安装](https://github.com/happinesslijian/VM/tree/master/VM%E5%AE%89%E8%A3%85nfs)
## k8s使用NFS做持久化动态存储
```
cd nfs/nfs-storageclass
kubectl apply -f .
``` 
### 验证：
- 如下图：

![微信截图_20190814153850.png](https://i.loli.net/2019/08/14/8DXF3h5mrQ2j4OS.png)
# Example
### 创建例子
```
cd Example
kubectl create -f .
```
### 创建完成之后可以看到会自动创建出PV和PVC证明已经成功
+ 如下图：
![微信截图_20190814160011.png](https://i.loli.net/2019/08/14/XlTf3eRjiPyYGom.png)
### 现在在nfs服务器端存储目录可以看到已经出现的文件夹
- 如下图：
![微信截图_20190814160432.png](https://i.loli.net/2019/08/14/P8mfrRMXKeg2vxL.png)
