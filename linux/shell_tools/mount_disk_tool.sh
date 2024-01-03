#!/usr/bin/env bash
##############################################################################
# Function：磁盘挂载工具
# Parameters：无
# Author： rong.li
# Date：2023-02-06
##############################################################################
############### 参数配置区
# 可用块设备名称 请通过执行：lsblk 命令列出当前系统所有可用块设备的信息
DISK=sda
# 挂载目标路径
TARGET_DIR=/data01
##############################################################################

# 1.格式化硬盘，-f 表示强制
mkfs.xfs -f /dev/$DISK

sleep 3
# 判断上一个命令执行状态，硬盘格式化成功，继续往下执行
if [ $? -eq 0 ];then
    # 2.创建挂载目标路径
    mkdir -p $TARGET_DIR
    # 3.挂载磁盘到指定目标路径
    mount /dev/$DISK $TARGET_DIR
    # 4.获取挂载后的：uuid
    UUID=`ls -l /dev/disk/by-uuid|grep $DISK|awk '{print $9}'`
    if [ $UUID"x" != "x" ];then
    # 5.将uuid 磁盘挂载信息写入  /etc/fstab 配置文件，确保永久生效
    # tips1：/etc/fstab文件的作用 磁盘被手动挂载之后都必须把挂载信息写入/etc/fstab这个文件中,否则下次开机启动时仍然需要重新挂载
    cat >>/etc/fstab<<EOF
UUID=$UUID  /data                  xfs    defaults        0 0
EOF
    echo "mount disk success"
    else
        echo "mount disk fail"
    fi
else
    echo "mkfs disk fail"
fi
# 查看全部挂载信息
mount -a
# 查看磁盘信息
df -lh