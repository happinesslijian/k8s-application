# 内网文件服务器droppy

> 背景：有很多时候我们需要从外网批量重复下载很多东西,尤其有的包托管在github上,天朝的网络真的很感人,下载半天都下载不成功,这时候就需要一个内网文件服务器的出现了,只要把需要的包放在内网服务器上,其他机器指定从内网机器下载,这时候下载速度岂不是很有保障！说干就干,本篇文章介绍了一个极简的工具droppy,文章示例将其运行在k8s内,并做持久化。

官方地址：https://github.com/silverwind/droppy
- deoppy配置文件如下：  
```
apiVersion: v1
kind: Namespace
metadata:
  name: droppy
---
apiVersion: v1
kind: Service
metadata:
  name: droppy
  namespace: droppy
  labels:
    app: droppy
spec:
  ports:
    - port: 8989
      targetPort: 8989
      nodePort: 32767
  type: NodePort
  selector:
    app: droppy
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: droppy-pv
spec:
  capacity:
    storage: 10Gi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  nfs:
    path: /data/droppy/
    server: 10.20.80.206
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: droppy-pvc
  namespace: droppy
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Gi
---
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: droppy
  name: droppy
  namespace: droppy
spec:
  selector:
    matchLabels:
      app: droppy
  replicas: 1
  strategy:
    type: Recreate
  template:
    metadata:
      labels:
        app: droppy
    spec:
      containers:
        - image: silverwind/droppy:latest
          imagePullPolicy: IfNotPresent
          name: droppy
          ports:
            - containerPort: 8989
          resources:
            limits: 
              cpu: 1000m
              memory: 500Mi
            requests:
              cpu: 1000m
              memory: 500Mi
          volumeMounts:
          - name: files
            mountPath: /files
      restartPolicy: Always
      volumes:
        - name: files
          persistentVolumeClaim:
            claimName: droppy-pvc
```
> 我这里使用的nfs做为存储,并把droppy容器的/files目录映射到PVC上,来实现持久化
- dashboard

> 用户名 admin  
  密码   admin

![](https://imgkr.cn-bj.ufileos.com/634d1b7f-2f24-432c-a5be-0b2d2c4e041e.png)

- 下载
```
wget http://10.20.80.203:8989/$/FkP9Z -P test

# 上传到droppy的文件会被重命名,如上命令所示,推荐下载命令如下：

curl -o test/grafana-7.1.0-1.x86_64.rpm http://10.20.80.203:8989/$/FkP9Z
```
