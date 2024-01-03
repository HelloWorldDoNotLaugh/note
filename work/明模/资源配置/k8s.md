## 1. 环境登陆

```shell
ssh tdops@10.58.12.9
```

## 2. pod启动失败

大概率是因为pod启动的太多。可以删除状态为失败的pod

```shell
# 删除指定状态的pod
kubectl delete pod -A --field-selector=status.phase=Failed
kubectl delete pod -A --field-selector=status.phase=Pending
```

