# 此项目都在k8s集群内部署
|应用名称|作用|端口|部署环境|
|:--:|:--:|:--:|:--:|
|[efk](https://github.com/happinesslijian/k8s-application/tree/master/EFK)|日志收集分析展示|9200/9300/5601|kubeadm v1.15.1|
|[harbor](https://github.com/happinesslijian/k8s-application/tree/master/helm-install-harbor)|容器仓库|80/6060/5432/4443/7899/6379/5000/8080|kubeadm v1.15.1|
|[nfs-StorageClass](https://github.com/happinesslijian/k8s-application/tree/master/nfs)|动态存储|None|kubeadm v1.15.1|
|[prometheus-operator](https://github.com/happinesslijian/k8s-application/tree/master/prometheus-operator)|动态存储prometheus-operator监控数据|None|kubeadm v1.15.1|
|[update-kubernetes](https://github.com/happinesslijian/k8s-application/tree/master/update-kubenetes)|升级k8s|None|kubeadm v1.15.1|
|[istio](https://github.com/happinesslijian/k8s-application/tree/master/istio)|微服务治理||kubeadm v1.15.1|
|[ingress-nginx&Basic Auth](https://github.com/happinesslijian/k8s-application/tree/master/ingress-nginx%26Basic%20Auth)|服务发现/域名访问|80/443|kubeadm v1.15.1|
|[openldap](https://github.com/happinesslijian/k8s-application/tree/master/ldap)|统一认证用户|389|kubeadm v1.15.1|
|[nextcloud](https://github.com/happinesslijian/k8s-application/tree/master/nextcloud)|私有云服务|80/8080/3306|kubeadm v1.15.1|
|[solo](https://github.com/happinesslijian/k8s-application/tree/master/solo)|solo博客系统|8080/3306|kubeadm v1.15.1|
|[zabbix]()|监控系统|10051/10052|v1.15.6|
