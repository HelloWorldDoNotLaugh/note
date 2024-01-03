## 生成ssh key

```shell
ssh-keygen -t ed25519 -C "your_email@example.com"

#Note: If you are using a legacy system that doesn't support the Ed25519 algorithm, use:
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

然后一直敲 enter

