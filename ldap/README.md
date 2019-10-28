# helm部署openldap
### 说明：使用[helm](https://github.com/happinesslijian/k8s-application/tree/master/helm-install-harbor/install%20helm%20v2.14.1)安装,使用ldapAdmin来管理即可 提前准备一个[storageclass](https://github.com/happinesslijian/k8s-application/tree/master/nfs)
安装openldap服务
```
$kubectl create ns ldap
$helm fetch --untar stable/openldap
$cd openldap
$wget https://raw.githubusercontent.com/happinesslijian/k8s-application/master/ldap/ldap-values.yaml
$helm install --name ldap -f ldap-values.yaml . --namespace=ldap
$kubectl get pod,svc -n ldap
NAME                               READY   STATUS    RESTARTS   AGE
pod/ldap-openldap-fd74994b-8229j   1/1     Running   0          43m

NAME                    TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                       AGE
service/ldap-openldap   NodePort   10.244.64.24   <none>        389:30908/TCP,636:30449/TCP   43m
```
## ldapAdmin
- [配置验证如图](https://i.loli.net/2019/10/21/D57wM1GnQXziaC9.png)

## 接入应用设置
- [接入jumpserver设置](https://i.loli.net/2019/09/20/IRidulCYjp8BPbW.png)
- [接入nextcloud](https://www.orgleaf.com/2839.html)
- [接入容器gitlab应用](https://i.loli.net/2019/09/21/eSHlx5pnWf34PIz.png)
  - 这里使用的是helm安装的gitlab，内容填写在values.yaml文件里
  - 代码如下：
```
    LDAP_ENABLED: true
    LDAP_LABEL: LDAP
    LDAP_HOST: 192.168.100.150
    LDAP_PORT: 389
    LDAP_UID: uid
    LDAP_BIND_DN: cn=admin,dc=dycd,dc=com
    LDAP_PASS: passwd
    LDAP_TIMEOUT: 10
    LDAP_METHOD: plain
    LDAP_VERIFY_SSL: false
    LDAP_ACTIVE_DIRECTORY: false
    LDAP_ALLOW_USERNAME_OR_EMAIL_LOGIN: false
    LDAP_BASE: ou=gitlab,dc=dycd,dc=com
```
  - 判断LDAP是否连接成功可以连接到pod内查看
```
# kubectl exec -it gitlab-gitlab-core-0 /bin/bash -n gitlab
# ./bin/rake gitlab:ldap:check
```
[如图所示](https://i.loli.net/2019/09/22/pqN2M5rRestVYLc.png)
