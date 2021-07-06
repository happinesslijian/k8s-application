#!/bin/bash

#参考链接：https://github.com/kubernetes-csi/csi-driver-nfs

ver="master"

repo="https://ghproxy.com/https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/$ver/deploy"

echo "Download NFS CSI driver files, version: $ver ..."
curl -OL $repo/rbac-csi-nfs-controller.yaml
curl -OL $repo/csi-nfs-driverinfo.yaml
curl -OL $repo/csi-nfs-controller.yaml
curl -OL $repo/csi-nfs-node.yaml
echo 'NFS CSI driver files download successfully.'

#如果集群没有翻墙,自行修改yaml文件中的images改到国内可以正常pull
#linux翻墙：
vim /etc/profile/
http_proxy=10.110.128.49:8118
https_proxy=$http_proxy
export http_proxy https_proxy
#source /etc/profile