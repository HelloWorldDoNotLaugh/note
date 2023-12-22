#!/usr/bin/env bash
##############################################################################
# Function：发送文件到多台机器指定目录
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
################ 参数配置区
# 脚本内全局常量定义
# 1.发送文件-指定机器列表，多台以逗号相隔
HOSTS=10.57.16.190,10.57.16.190
# 2.发送文件-指定目录
FILE_DIR=/data01/td01/yuntu/python3/py-script
# 3.待发送文件
FILE_NAME=checklist_snap.py
# 4.操作用户
INSTALL_USER=tdops
##############################################################################
servers=($(echo $HOSTS | tr "," "\n"))
##############################################################################
# Function：发送python脚本到指定机器目录
# Parameters：无
##############################################################################
scp_py_script()
{
  for (( i = 1; i <= ${#servers[*]}; i++ )); do
		server=${servers[$(($i-1))]}
		echo "send file to $server start."
		ssh $INSTALL_USER@$server "mkdir -p $FILE_DIR"
		scp $FILE_NAME $INSTALL_USER@$server:$FILE_DIR
		echo "send file to $server success."
	done
  return 0
}

main()
{
  # main方法内调度执行其他方法
  scp_py_script
}

##############################################################################
# shellcheck disable=SC2068
main $@
cd $CUR_PATH
##############################################################################