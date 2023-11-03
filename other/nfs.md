## nfs安装

### nfs service安装

* 优先创建好共享文件夹
* 确认安装的用户

```shell
echo '切换安装nfs用户'
#sudo su
  
echo '一.安装:nfs-utils'
yum -y install nfs-utils
  
echo '二.共享规则配置(vim /etc/exports)'
mkdir -p /nfs-share
sudo tee /etc/exports <<-'EOF'
/nfs-share   *(rw,sync,no_subtree_check,no_root_squash)
EOF
  
echo '先为rpcbind和nfs做开机启动'
systemctl enable rpcbind.service
systemctl enable nfs-server.service
  
echo '分别启动rpcbind和nfs服务'
systemctl restart rpcbind.service
systemctl restart nfs.service
  
echo '查看service列中是否有nfs服务来确认NFS是否启动'
IP=`ip a|grep -w 'inet'|grep 'global'|sed 's/^.*inet //g'|sed 's/\/[0-9][0-9].*$//g'`
echo $IP
showmount -e $IP
  
echo '准备业务挂载目录'
mkdir -p /nfs-share/holmes/model
mkdir -p /nfs-share/holmes/task

echo '切换目录权限用户(修改为部署应用的用户)'
chgrp admin /nfs-share -R
chown admin /nfs-share -R
```

### nfs client安装

```shell
echo '一.安装:nfs-utils'
yum install -y nfs-utils
  
echo '二.开机启动 & 启动服务'
systemctl enable rpcbind.service
systemctl start rpcbind.service
  
echo '检查nfs服务(手动更新nfs-Servie-Ip)'
nfsServiceIP=10.57.16.13
showmount -e $nfsServiceIP
  
echo '挂载节点(注意文件夹需事先存在)'
mount -t nfs $nfsServiceIP:/nfs-share/holmes/model /home/admin/model
mount -t nfs $nfsServiceIP:/nfs-share/holmes/task /home/admin/task
  
echo '查看client端NFS挂载情况'
df -h
#文件系统                               容量 已用 可用 已用% 挂载点
#10.57.16.13:/nfs-share/holmes/model   20G   15G 4.9G   76% /home/admin/model
#10.57.16.13:/nfs-share/holmes/task   20G   15G 4.9G   76% /home/admin/task
# 卸载NFS挂载
# umount -l /home/admin/model
# umount -l /home/admin/task
```

### 配置节点挂载

```shell
mount -t nfs $nfsServiceIP:/nfs-share/holmes/model /home/admin/model
```

