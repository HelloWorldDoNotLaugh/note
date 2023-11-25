## 写在前面的几个重要命令
1. docker与本地件的文件拷贝
```shell
# 查看容器ID
docker ps -a

# 本地文件拷本到容器
docker cp {local_path} {CONTAINER ID}:{path}

# 容器拷本到本地
docker cp {CONTAINER ID}:{path} {local_path} 

# eg
docker cp /Users/helloworld/Downloads/R-3.5.0 0a1d7db7946:/tmp/
```
2. 报错解决 http: server gave HTTP response to HTTPS client
```shell
这是因为我们[docker](https://so.csdn.net/so/search?q=docker&spm=1001.2101.3001.7020) client使用的是https，而我们搭建的Harbor私库用的是http的

编辑 /etc/docker/daemon.json 

添加私服地址
{"insecure-registries":["仓库ip:port"]}
# 重启docker
sudo systemctl daemon-reload
sudo systemctl restart docker
```
3.docke load 后找不到镜像
```shell
# docker load 后弹出的sha256的前几位就是镜像ID
# 模糊查询即可
docker images --format '{{.ID}}' | grep '^709f2bc'
```

## 1. 制作镜像

### 1.1 编写Dockerfile

```shell
FROM ubuntu:14.04
MAINTAINER "name" <email>
RUN apt-get update
RUN apt-get install -y nginx
EXPOSE 80
CMD ["nginx"]
```

### 1.2 构建镜像

```shell
docker build -t nginx.
```

## 2. 镜像相关

### 2.1 查看当前所有镜像

```shell
docker images
```
### 2.2 删除镜像

```shell
docker rmi <image_name>
```
### 2.3 上传镜像到仓库
```shell
docker push <image_name>
```

### 2.4 从仓库下载镜像

```shell
docker pull <image_name>
```

### 2.5 镜像标签

```shell
docker tag <image_name> <new_image_name>
```

### 2.6 保存镜像文件

```shell
docker save -o <image_name>.tar <image_name>
```

### 2.7 导入镜像文件

```shell
docker load -i <image_name>.tar
```

##

## 3. 容器相关

### 3.1 运行镜像-启动容器

```shell
docker run -d -p 80:80 nginx
```

### 3.2 停止容器

```shell
docker stop <container_id>
```

### 3.3 删除容器

```shell
docker rm <container_id>
```

### 3.4 查看运行日志

```shell
docker logs <container_id>
```

### 3.5 进入容器

```shell
docker exec -it <container_id> /bin/bash

docker exec -it <container_id> sh
```

### 3.6 导出容器

```shell
docker export <container_id> > <container_name>.tar
```

### 3.7 导入容器

```shell
docker import <container_name>.tar
```
## 4. 容器网络

### 4.1 查看容器网络

```shell
docker network ls
```

### 4.2 创建容器网络

```shell
docker network create <network_name>
```

### 4.3 删除容器网络

```shell
docker network rm <network_name>
```

### 4.4 连接容器到网络

```shell
docker network connect <network_name> <container_id>
```
## 5. 容器数据卷

### 5.1 查看容器数据卷

```shell
docker volume ls
```

### 5.2 创建容器数据卷

```shell
docker volume create <volume_name>
```

### 5.3 删除容器数据卷

```shell
docker volume rm <volume_name>
```

### 5.4 挂载容器数据卷

```shell
docker run -d -v <host_path>:<container_path> <image
docker run -d -v /home/data/mysql:/var/lib/mysql mysql
```

## 6. 跑路系列操作

### 6.1 删除全部容器

```shell
docker rm $(docker ps -a -q)
```

### 6.2 删除全部镜像

```shell
docker rmi $(docker images -q)
```

### 6.3 删除全部数据卷

```shell
docker volume rm $(docker volume ls -q)
```

### 6.4 删除全部网络

```shell
docker network rm $(docker network ls -q)
```

### 6.5 删除所有未运行的容器、未使用的镜像、数据卷、网络

```shell
docker system prune -a
```



