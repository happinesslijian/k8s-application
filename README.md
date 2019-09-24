# 此项目都在k8s集群内部署
|应用名称|作用|端口|部署环境|
|:--:|:--:|:--:|:--:|
|[efk]()|日志收集分析展示|9200/9300/5601|kubeadm v1.15.1|
|[harbor]()|容器仓库|80/6060/5432/4443/7899/6379/5000/8080|kubeadm v1.15.1|
|[nfs-StorageClass]()|动态存储|None|kubeadm v1.15.1|
|[prometheus-operator]()|动态存储prometheus-operator监控数据|None|kubeadm v1.15.1|
|[update-kubernetes]()|升级k8s|None|kubeadm v1.15.1|