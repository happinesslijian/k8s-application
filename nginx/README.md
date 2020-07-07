# 简单说明
nginx.yaml  
记录一下只挂载 **`nginx.conf`** 单个文件到/etc/nginx/目录下  
指定了configmap名字之后使用 **`items`** 指定文件名和目录  
同时这个文件nginx也是关联前后端的代理
```
          volumeMounts:
            - name: config-volume
              mountPath: /etc/nginx/nginx.conf
              subPath: nginx.conf
            - name: daima
              mountPath: /usr/share/nginx/html/
      restartPolicy: Always
      volumes:
        - name: config-volume
          configMap:
            name: nginx-cm
            items:
              - key: nginx.conf
                path: nginx.conf
        - name: daima
          persistentVolumeClaim:
            claimName: nginx-pvc
```