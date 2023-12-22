#!/usr/bin/env bash
##############################################################################
# Function：同盾企业级软件-安装前准备
# Parameters：无
# Author： huabo.zhang
# Date：2023-09-06
##############################################################################

##############################################################################
# 需要安装准备的机器参数
##############################################################################
# 安装机器列表
INSTALL_PREPARATION_HOSTS=10.57.242.222
# 安装使用的root权限用户
INSTALL_PREPARATION_ROOT_USER=root
##############################################################################
# 安装准备配置参数
##############################################################################
#挂载磁盘名称(查看服务器磁盘:sudo fdisk -l )
MOUNT_DISK_NAME=vdb
#挂载目标路径
MOUNT_TARGET_DIR=/data01
#格式化磁盘类型(ext4,xfs,默认ext4)
MOUNT_MKFS_TYPE=ext4

#安装机器的用户组
INSTALL_USER_GROUP=admin
#安装机器的用户名
INSTALL_USER_NAME=admin
#安装机器的登陆密码
INSTALL_USER_PASSWORD=admin123456
#安装机器的根目录
INSTALL_ROOT_DIR=/data01/td
#安装机器的子目录
INSTALL_SUB_DIR=infra,tiance,tmp
#客户提供NTP服务器(时间同步)
CUSTOMER_NTP_SERVER=
##############################################################################
# echo打印
##############################################################################
function_head_echo(){
  echo "##############################################################################"
  echo "进行操作：$1"
  echo "##############################################################################"
}
##############################################################################
# 挂载磁盘
##############################################################################
mount_disk(){
  function_head_echo "挂载磁盘"

  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo "用于挂载的磁盘:$MOUNT_DISK_NAME"
  echo "格式化磁盘类型:$MOUNT_MKFS_TYPE"
  echo "挂载的目录路径:$MOUNT_TARGET_DIR"
  echo "***输出如上内置中\“Disk /dev/vda\”、\“Disk /dev/vdb\”属于磁盘***"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  #查看服务器磁盘
  echo ">>>>>>查看服务器磁盘：fdisk -l<<<<<"
  sudo fdisk -l
  echo ">>>>>>查看磁盘是否被挂载：sudo lsblk /dev/$MOUNT_DISK_NAME<<<<<"
  sudo lsblk /dev/$MOUNT_DISK_NAME
  while true; do
      read -p "检查挂载磁盘是否正确，并继续操作? [y/n]" yn
      case $yn in
          [Yy]* ) break;;
          [Nn]* ) exit;;
          * ) echo "请输入Y/N.";;
      esac
  done
  # 1.格式化硬盘
  if [ "${MOUNT_MKFS_TYPE}" == "xfs" ];then
    echo ">>>>>>格式化硬盘:mkfs.${MOUNT_MKFS_TYPE} -f /dev/$MOUNT_DISK_NAME<<<<<"
    sudo mkfs.${MOUNT_MKFS_TYPE} -f /dev/$MOUNT_DISK_NAME
  else
    echo ">>>>>>格式化硬盘:mkfs.${MOUNT_MKFS_TYPE} /dev/$MOUNT_DISK_NAME<<<<<"
    sudo mkfs.${MOUNT_MKFS_TYPE} /dev/$MOUNT_DISK_NAME
  fi
  sleep 3
  # 判断上一个命令执行状态，硬盘格式化成功，继续往下执行
  if [ $? -eq 0 ];then
      # 2.创建挂载目标路径
      sudo mkdir -p $MOUNT_TARGET_DIR
      # 3.挂载磁盘到指定目标路径
      sudo mount /dev/$MOUNT_DISK_NAME $MOUNT_TARGET_DIR
      # 4.获取挂载后的：uuid
      UUID=`ls -l /dev/disk/by-uuid|grep $MOUNT_DISK_NAME|awk '{print $9}'`
      if [ "$UUID" != "" ];then
        # 5.将uuid 磁盘挂载信息写入  /etc/fstab 配置文件，确保永久生效
        # tips1：/etc/fstab文件的作用 磁盘被手动挂载之后都必须把挂载信息写入/etc/fstab这个文件中,否则下次开机启动时仍然需要重新挂载
        echo "UUID=$UUID  /data                  xfs    defaults        0 0" | sudo tee -a /etc/fstab
        echo ">>>>>>挂载磁盘成功<<<<<"
      else
          echo ">>>>>>挂载磁盘失败<<<<<"
      fi
  else
      echo ">>>>>>挂载磁盘失败<<<<<"
  fi
  # 查看全部挂载信息
  sudo mount -a
  # 查看磁盘信息
  sudo df -lh
}

##############################################################################
# 创建用户
##############################################################################
create_user(){
  function_head_echo "创建用户"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo "用 户 组:$INSTALL_USER_GROUP"
  echo "用户名称:$INSTALL_USER_NAME"
  echo "用户密码:$INSTALL_USER_PASSWORD"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  while true; do
      read -p "检查创建用户参数是否正确，并继续操作? [y/n]" yn
      case $yn in
          [Yy]* ) break;;
          [Nn]* ) exit;;
          * ) echo "请输入Y/N.";;
      esac
  done
  # 创建用户组
  sudo groupadd $INSTALL_USER_GROUP
  # 创建用户
  sudo useradd -g $INSTALL_USER_GROUP -m $INSTALL_USER_NAME
  # 设置用户密码
  echo "$INSTALL_USER_PASSWORD" | sudo passwd --stdin $INSTALL_USER_NAME
  #设置用户免密sudo权限
  echo "$INSTALL_USER_NAME ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
}

##############################################################################
# 创建部署目录
##############################################################################
create_deploy_dir(){
  function_head_echo "创建部署目录"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  echo "创建主目录:$INSTALL_ROOT_DIR"
  echo "授权用户组:$INSTALL_USER_GROUP"
  echo "授权用户:$INSTALL_USER_NAME"
  echo ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
  while true; do
      read -p "检查创建用户参数是否正确，并继续操作? [y/n]" yn
      case $yn in
          [Yy]* ) break;;
          [Nn]* ) exit;;
          * ) echo "请输入Y/N.";;
      esac
  done
  # 创建主目录
  sudo mkdir -p $INSTALL_ROOT_DIR
  # 设置所属用户
  sudo chown $INSTALL_USER_NAME:$INSTALL_USER_GROUP $INSTALL_ROOT_DIR
  # 创建子目录
  install_sub_dirs=($(echo $INSTALL_SUB_DIR | tr "," "\n"))
  for (( i = 1; i <= ${#install_sub_dirs[*]}; i++ )); do
    		install_sub_dir=${install_sub_dirs[$(($i-1))]}
    		mkdir -p $INSTALL_ROOT_DIR/$install_sub_dir
  done
  # 设置目录权限
  sudo chmod 777 -R $INSTALL_ROOT_DIR
  ls -la $INSTALL_ROOT_DIR
}

##############################################################################
# 检查时区&时间同步
##############################################################################
datetime_sync(){
  function_head_echo "检查时区&时间同步"
  #检查时区
  echo "是否显示\"Asia/Shanghai (CST, +0800)\"时区，如果系统时区不是指定时区，需要修改时区"
  sudo timedatectl set-timezone Asia/Shanghai
  #时间同步
  ##查看时间同步服务器列表，如果客户提供专属时间同步NTP服务器，则进行step2
  chronyc -n sources -v
  ##编辑文件/etc/chrony.conf,并在文件末尾添加以下行：
  if [ -z "$CUSTOMER_NTP_SERVER" ];then
      ##ip=客户提供NTP服务器
      server {ip} iburst
      ##重启chronyd服务&校验是否生效
      systemctl restart chronyd.service
      chronyc -n sources -v
  else
    echo "CUSTOMER_NTP_SERVER未配置，不能进行时间同步"
  fi
}

##############################################################################
# 系统优化
##############################################################################
system_optimization(){
  function_head_echo "系统优化"
  #1.用户和进程资源限制
  #编辑文件/etc/security/limits.conf,并在文件末尾添加以下行:
  #说明：* 代表针对所有用户;nproc 是代表最大进程数;nofile 是代表最大文件打开数。
  echo ">>>设置用户和进程资源限制"
  sudo sed -i -e '/soft nproc/d' -e '/hard nproc/d' /etc/sysctl.conf
  sudo sed -i -e '/soft nofile/d' -e '/hard nofile/d' /etc/sysctl.conf
  sudo sed -i -e '/soft memlock/d' -e '/hard memlock/d' /etc/sysctl.conf
  cat <<EOF | sudo tee -a /etc/security/limits.conf
*  soft nproc   65535
*  hard nproc   65535
*  soft nofile   65535
*  hard nofile   65535
*  soft memlock unlimited
*  hard memlock unlimited
EOF
  #重新加载PAM配置
  echo ">>>sudo systemctl restart systemd-logind"
  sudo systemctl restart systemd-logind

  #2.内核文件参数
  #/etc/sysctl.conf,并在文件末尾添加以下行:
  echo ">>>设置内核文件参数"
  sudo sed -i -e '/fs.file-max/d' -e '/vm.max_map_count/d' /etc/sysctl.conf
  cat <<EOF | sudo tee -a /etc/sysctl.conf
fs.file-max = 1000000
vm.max_map_count = 100000000
EOF
  echo ">>>sudo sysctl -p"
  #生效操作
  sudo sysctl -p

  #3.用户limit
  echo ">>>设置用户limit"
  #查看是否存在90-nproc.conf或者20-nproc.conf，执行步骤(2)
  ls /etc/security/limits.d/
  #(2-A)存在90-nproc.conf则编辑文件/etc/security/limits.d/90-nproc.conf
  if [ -f "/etc/security/limits.d/90-nproc.conf" ];then
    echo ">>>编辑文件/etc/security/limits.d/90-nproc.conf"
    echo ">>>设置：* soft nproc 655360"
    sudo sed -i '/soft nproc/d' /etc/security/limits.d/90-nproc.conf
    echo "* soft nproc 655360" | sudo tee -a /etc/security/limits.d/90-nproc.conf
  fi
  #(2-B)存在20-nproc.conf则编辑文件/etc/security/limits.d/20-nproc.conf
  if [ -f "/etc/security/limits.d/20-nproc.conf" ];then
    echo ">>>编辑文件/etc/security/limits.d/90-nproc.conf"
    echo ">>>设置：* soft nproc 655360"
    sudo sed -i '/soft nproc/d' /etc/security/limits.d/20-nproc.conf
    echo "* soft nproc 655360" | sudo tee -a /etc/security/limits.d/20-nproc.conf
  fi
  echo ">>>查看结果 "
  sudo cat /etc/security/limits.conf
}

##############################################################################
# 系统优化
##############################################################################
network_optimization(){
  #(1)编辑文件/etc/sysctl.conf,并在文件末尾添加以下行:
  #添加内容(已存在则修改)
  echo ">>>备份/etc/sysctl.conf为/etc/sysctl.conf.bk"
  sudo cp /etc/sysctl.conf /etc/sysctl.conf.bk
  sudo sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_fin_timeout/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_syncookies/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_tw_reuse/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_tw_recycle/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_keepalive_time/d' /etc/sysctl.conf
  sudo sed -i '/net.core.netdev_max_backlog/d' /etc/sysctl.conf
  sudo sed -i '/net.core.rmem_max/d' /etc/sysctl.conf
  sudo sed -i '/net.core.wmem_max/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_wmem/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.ip_local_port_range/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_synack_retries/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_syn_retries/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_keepalive_probes/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv4.tcp_max_tw_buckets/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv6.conf.lo.disable_ipv6/d' /etc/sysctl.conf
  sudo sed -i '/net.ipv6.conf.eth0.disable_ipv6/d' /etc/sysctl.conf
  sudo sed -i '/vm.max_map_count/d' /etc/sysctl.conf
  sudo sed -i '/vm.swappiness/d' /etc/sysctl.conf
  echo ">>>修改sy/sctl.conf"
  cat <<EOF | sudo tee -a /etc/sysctl.conf
net.ipv4.tcp_fin_timeout=20
net.ipv4.tcp_syncookies=1
net.ipv4.tcp_tw_reuse=1
net.ipv4.tcp_tw_recycle=1
net.ipv4.tcp_keepalive_time=1200
net.core.netdev_max_backlog = 262144
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_wmem = 4096 16384 4194304
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_synack_retries = 2
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_keepalive_probes = 2
net.ipv4.tcp_max_tw_buckets = 360000
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv6.conf.eth0.disable_ipv6 = 1
vm.max_map_count = 67108864
vm.swappiness = 1
EOF
  #(2)生效操作
  echo ">>>生效操作 "
  sudo sysctl -p
  echo ">>>查看结果 "
  sudo cat /etc/sysctl.conf
}

##############################################################################
# 设置系统字符集
##############################################################################
set_locale(){
  function_head_echo "设置系统字符集"
  # 设置系统字符集为UTF-8
  sudo locale-gen en_US.UTF-8
  sudo update-locale LANG=en_US.UTF-8
  # 重新加载当前终端的环境变量
  source ~/.bashrc
  sudo locale | grep LANG
}

##############################################################################
# 关闭防火墙
##############################################################################
close_firewalld(){
  function_head_echo "关闭防火墙"
  sudo systemctl status firewalld
  sudo systemctl stop firewalld
}

##############################################################################
# 远程执行命令
##############################################################################
INSTALL_PREPARATION_SCRIPT_NAME="install_preparation.sh"
install_preparation_servers=($(echo $INSTALL_PREPARATION_HOSTS | tr "," "\n"))
remote_install(){
  for (( i = 1; i <= ${#install_preparation_servers[*]}; i++ )); do
  		server=${install_preparation_servers[$(($i-1))]}
  		scp $INSTALL_PREPARATION_SCRIPT_NAME $INSTALL_PREPARATION_ROOT_USER@$server:~/
  		ssh -t $INSTALL_PREPARATION_ROOT_USER@$server ". /etc/profile; . ~/.bashrc; cd ~/;sh $INSTALL_PREPARATION_SCRIPT_NAME $2"
  		ssh $INSTALL_PREPARATION_ROOT_USER@$server "rm ~/$INSTALL_PREPARATION_SCRIPT_NAME"
  done
}

##############################################################################
# 安装辅助软件
##############################################################################
#4.8.unzip命令支持
#部分安装包是以zip格式提供，因此服务器需要拥有unzip命令功能来解压文件。
#(1)校验系统是否已存在unzip功能，不存在则需要执行step2安装
#unzip -v
#
#输出类似"UnZip 6.00 of 20 April 2009, by Info-ZI"表示系统已支持unzip。
#(2)上传安装包unzip-6.0-21.el7.x86_64.rpm至/data01/td/infra
## 部署
#sudo rpm -ivh unzip-6.0-21.el7.x86_64.rpm
#4.9.netstat命令支持
#(1)校验系统是否已存在netstat功能，不存在则需要执行step2安装
##校验命令是否已支持
#netstat  --version
#
#net-tools 2.10-alpha
#Fred Baumgarten, Alan Cox, Bernd Eckenfels, Phil Blundell, Tuan Hoang, Brian Micek and others
#+NEW_ADDRT +RTF_IRTT +RTF_REJECT +FW_MASQUERADE +I18N +SELINUX
#
#输出如上则表示当前服务器已支持netstat
#(2)上传安装包net-tools-2.0-0.25.20131004git.el7.x86_64.rpm至/data01/td/infra
## 部署
#sudo rpm -ivh net-tools-2.0-0.25.20131004git.el7.x86_64.rpm

help(){
	echo "./install_preparation.sh [mount_disk|create_user|create_deploy_dir|datetime_sync|system_optimization|network_optimization|close_firewalld|remote_install|help]"
}

install_preparation_main(){
  case "$1" in
      all)
          mount_disk $@
          create_user $@
          create_deploy_dir $@
          set_locale $@
          datetime_sync $@
          system_optimization $@
          network_optimization $@
          close_firewalld $@
      ;;
      mount_disk)
          mount_disk $@
      ;;
      create_user)
          create_user $@
      ;;
      create_deploy_dir)
          create_deploy_dir $@
      ;;
      datetime_sync)
          datetime_sync $@
      ;;
      system_optimization)
          system_optimization $@
      ;;
      network_optimization)
          network_optimization $@
      ;;
      close_firewalld)
          close_firewalld $@
      ;;
      set_locale)
          set_locale $@
      ;;
      remote_install)
          remote_install $@
      ;;
      help)
          help
      ;;
      *)
      	help
      ;;
  esac
  echo "install_preparation.sh $1 finished."
}

install_preparation_main $@