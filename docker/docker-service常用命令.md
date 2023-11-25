## 服务启动

### configurable-http-proxy

```shell
sudo docker service create --replicas 1 --name sd_config-http-proxy \
	--env CONFIGURABLE_PROXY_REDIS_URI=redis://:12345@10.57.34.196:6379 \
	-p 8044:8044 -p 8088:8088 \
	10.57.17.244:5000/ml/configurable-http-proxy:1.0.0
```

### 启动holems-python

```shell
sudo docker service create --name service-holmes-python --replicas 2 \
  -e redis_url=redis://10.58.12.9:32560 -p 9003:9003 \
  --mount type=bind,source=/data01/nfs/holmes/model,target=/home/admin/model \
  --mount type=bind,source=/data01/nfs/holmes/task,target=/home/admin/task \
  10.57.17.244:5000/cd/holmes-python-qiye:feature-2-5-4-2324
```

## 信息查询

### 1. 当前运行的服务

```shell
docker service ls

## 停止服务
docker service rm ${serviceId}
```



### 2. 服务日志查询

```shell
docker service logs ${serviceId}

## 刷新
docker service logs -f ${serviceId}
```

### 3. 查询服务信息

```shell
sudo docker service inspect  ${serviceId}
# 只查询容器内ip
sudo docker service inspect -f '{{range .Endpoint.VirtualIPs}}{{.Addr}}{{end}}' ${serviceId}
```

