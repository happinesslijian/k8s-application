# prometheus-operator
prometheus-operator使用两种不同方式进行存储
根据实际环境需求进行选择 \
**环境说明：**

| IP| storageClassName|PROVISIONER|type
|:--:|:--:|:--:|:--:|
|192.168.100.150|prometheus|ceph.com/cephfs|cephfs
|192.168.100.154|prometheus|fuseim.pri/ifs|nfs
