## 问题描述

```shell
17:44:48.454: [note] git -c credential.helper= -c core.quotepath=false -c log.showSignature=false push --progress --porcelain origin refs/heads/main:main
kex_exchange_identification: Connection closed by remote host
Connection closed by 198.18.2.99 port 22
fatal: Could not read from remote repository.
Please make sure you have the correct access rights
and the repository exists.
```

## 解决方案

1. 网上说的更新 ssh key 方案不可行

2. 根据官方文档中的：在 HTTPS 端口使用 SSH

   ```shell
   # 在配置文件中添加：(配置文件不存在，直接创建)
   Host github.com
       Hostname ssh.github.com
       Port 443
       User git
   ```

   
