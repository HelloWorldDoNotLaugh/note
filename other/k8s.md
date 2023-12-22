## 1. 创建depyloymet与pod

```shell
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
```

## 2. 查看状态

```shell
kubectl get deployments
kubectl get pods
kubectl get services
```

## 3. 查看日志

```shell
kubectl describe pod <pod-name>
```

## 4. 查看Deployment 事件

```shell
kubectl describe deployment rstudio-deployment
```



## 5. 启动本地镜像仓库

```shell
docker run -d -p 5001:5000 -v $(pwd):/registry --restart always --name registry registry:latest
docker tag 10.58.12.6:4001/mingmo/rstudio-with-nginx:arm-kylin_1117 127.0.0.1:5001/mingmo/rstudio-with-nginx:arm-kylin_1117

curl http://127.0.0.1:5001/v2/_catalog

minikube start --insecure-registry="127.0.0.1:5001"

 minikube dashboard
# 加载镜像 
minikube image load 10.58.12.6:4001/mingmo/rstudio-with-nginx:arm-kylin_1119_V3
#docker push 127.0.0.1:5001/mingmo/notebook:1.0-arm-kylin
# 查看本地镜像仓库的镜像
http://127.0.0.1:5001/v2/_catalog


kubectl apply -f deployment.yaml
kubectl apply -f service.yaml
minikube service notebook-service
```





```shell
docker run -p 8987:8787 \
  -p 8077:8077 \
  -e DISABLE_AUTH=true \
  -e ROOT=true \
  -e USERID=1001 \
  -e GROUPID=1001 \
  10.58.12.6:4001/mingmo/rstudio-with-nginx:arm-kylin_1119_V3

```



```
/Users/helloworld/.minikube/cache/images/arm64/127.0.0.1_5001/notebook_1.0.0
```



