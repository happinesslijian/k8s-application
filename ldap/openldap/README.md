# openldap
## openldap in k8s(存在问题！！！！)   
1. 克隆本项目到本地
```
git clone https://github.com/happinesslijian/openldap.git
```
2. 开始安装
- 首先要修改实际使用的域名
```
cd openldap/environment
vi my-env.startup.yaml
```
[如图所示](https://i.loli.net/2019/09/13/4BVKlE6FyGnkpXg.png)
- 修改完成之后将environment目录下的两个文件进行base64编码，分别把输出的编码复制粘贴到`ldap-secret.yaml`文件内
```
cat my-env.startup.yaml | base64 --wrap=0 
cat my-env.yaml | base64 --wrap=0
```
[如图所示](https://i.loli.net/2019/09/13/ghZ1T5kuaGp267l.png)
- 创建所有文件
```
kubectl create -f .
kubectl get pod,svc,ing,pvc -n public-service
```
[如图所示](https://i.loli.net/2019/09/13/1S68p9LcQGdEqNh.png)
- web页面查看效果并登陆
```
Login DN：cn=admin,dc=dycd,dc=test,dc=com
默认密码是 admin
```
[如图所示](https://i.loli.net/2019/09/13/5P6wF7VqDGgHct2.png) \
[如图所示](https://i.loli.net/2019/09/13/hncGua4DOSCeyJN.png)

3. 使用客户端管理 \
`保持汉化包和ldapadmin客户端程序在同一目录`
- [下载ldapAdmin](https://sourceforge.net/projects/ldapadmin/files/ldapadmin/1.6.1/LdapAdminExe-1.6.1.zip/download)
- [下载汉化包](http://www.ldapadmin.org/download/languages/download.php?id=3)
- [汉化配置过程](https://i.loli.net/2019/09/16/ruCpw1O8JUSYQ25.gif)
- [客户端登陆](https://i.loli.net/2019/09/13/Zpblfejohx54E2S.png)
