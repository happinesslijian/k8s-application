## 安装minio

#### 使用docker安装
- 搜索镜像
```
docker search minio
```
- 拉取镜像
```
docker pull minio/minio
- 启动镜像
- 自定义用户和秘钥安装
  - 这种安装方式 MinIO 自定义 Access 和 Secret 密钥要覆盖 MinIO 的自动生成的密钥，您可以将 Access 和 Secret 密钥设为环境变量。MinIO 允许常规字符串作为 Access 和 Secret 密钥
docker run -p 9000:9000 -p 9001:9001 --name minio \
-d --restart=always \
-e "MINIO_ROOT_USER=admin" \
-e "MINIO_ROOT_PASSWORD=admin123456" \
-v /home/data:/data \
-v /home/config:/root/.minio \
-v /etc/localtime:/etc/localtime \
minio/minio server /data --console-address ":9001"
```
- 安装客户端工具
  - docker方式安装 执行如下命令，完成安装，并进入容器内
```
docker run -it --entrypoint=/bin/sh minio/mc
```
  - 二进制方式安装
```
curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
mv mc /usr/local/bin/
chmod +x /usr/local/bin/mc
```
- 添加主机
MinIO 除了支持 MinIO 之外，还支持 aws 对象存储。本章节以 添加MinIO 云存储为例。
命令格式:
```
mc config host add <ALIAS> <YOUR-S3-ENDPOINT> <YOUR-ACCESS-KEY> <YOUR-SECRET-KEY> [--api API-SIGNATURE]
```
别名就是给你的云存储服务起了一个短点的外号。S3 endpoint,access key 和 secret key 是你的云存储服务提供的。API 签名是可选参数，默认情况下，它被设置为"S3v4"。

示例如下:
```
mc config host add minio http://10.121.141.118:9000 admin admin123456 --api s3v4
```
- 客户端工具的使用

```
# 删除主机
mc config host remove 主机名称
# 查询关联的主机列表
mc config host ls
# 创建桶
mc mb minio/bucket1
# 删除桶
mc rm minio/bucket1
# 删除有文件的桶
mc rb minio/bucket1 --force
# 查询某主机桶列表
mc ls 主机名称
# 上传文件
mc cp 本地文件路径 桶的路径
# 上传目录
mc cp /etc/ monio/bucker2 --recursive
# 下载
mc share download --expire 4h play/mybucket/myobject.txt
# 设置存储桶权限
mc policy set public minio/bucket1
```