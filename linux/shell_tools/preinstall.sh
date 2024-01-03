#!/usr/bin/env bash
##############################################################################
# Function：预安装配置：创建用户及授权、软件安装目录创建及授权
# Parameters：无
# Author： rong.li
# Date：2022-10-09
##############################################################################
# CUR_PATH：当前执行命令所在路径，BIN_DIR：被执行脚本所在路径
exe_cmd=$0
CUR_PATH=`pwd`
relative_dir=`dirname ${exe_cmd}`
cd $relative_dir
BIN_DIR=`pwd`
cd $CUR_PATH
##############################################################################
# 导入全局公共脚本
. $BIN_DIR/common_function.sh
. $BIN_DIR/config.ini
###需要修改配置 start###########################################################
# 待操作机器列表
preinstall_hosts=10.58.16.143
# 操作用户
root_user=tdops

# 待创建用户名
# ops_user=$USER
ops_user=yuntuops2
# 待创建用户密码
ops_user_pwd=Td@123456
# 操作类型：creat_user,create_base_path,passwordless
operate_type=creat_user
###需要修改配置 end  ###########################################################
# 以下内容禁止修改
servers=($(echo $preinstall_hosts | tr "," "\n"))

operate_result_log=$3
if [ "${operate_result_log}x" != "x" ]; then
  operate_result_log=$BIN_DIR/preinstall_result_$DATE_YMD.log
fi
##############################################################################
# Function：创建linux用户并授权sudo
# Parameters：无
##############################################################################
create_user()
{
  for (( i = 1; i <= ${#servers[*]}; i++ )); do
		server=${servers[$(($i-1))]}
		log_info "$server create user $ops_user starting! " $operate_result_log
		log_info "" $operate_result_log
		ssh $root_user@$server "sudo useradd $ops_user;echo $ops_user_pwd |sudo  passwd --stdin $ops_user;"
		log_info "$server create user $ops_user success." $operate_result_log
		log_info "" $operate_result_log
	done
  log_info "Create ops user $ops_user finished." $operate_result_log
  return 0
}

create_base_path()
{
  for (( i = 1; i <= ${#servers[*]}; i++ )); do
		server=${servers[$(($i-1))]}
		log_info "$server create install base path $ops_user starting! " $operate_result_log
		log_info
		ssh $root_user@$server "sudo mkdir -p $BASE_PATH;sudo chown -R $ops_user:$ops_user $BASE_PATH;"
		log_info "$server create install base path $ops_user success." $operate_result_log
		log_info
	done
  log_info "Create install base path $BASE_PATH finished." $operate_result_log
  return 0
}

main()
{
  case "$operate_type" in
    create_user)
        create_user
    ;;
    create_base_path)
        create_base_path
    ;;
    *)
    	log_info "sh $SCRIPT_NAME [install|check]" $operate_result_log
    ;;
  esac
  log_info "preinstall.sh execute finished." $operate_result_log
}

##############################################################################
# shellcheck disable=SC2068
main $@
cd $CUR_PATH
##############################################################################

# 常见问题1: sudo: sorry, you must have a tty to run sudo
# 解决方法：使用root 账号，vim /etc/sudoers 注释掉：# Default requiretty 该配置