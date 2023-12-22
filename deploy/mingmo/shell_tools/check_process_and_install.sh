#!/usr/bin/env bash
##############################################################################
# Function：软件安装前检查：是否已安装、是否已启动
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
###需要修改配置 start###########################################################
# 执行前请修改
# 预检查机器列表
precheck_hosts=10.58.16.145
# 检查用户
precheck_user=tdops

# 可选值（以,分隔）：
#  elastic
#  mysql
#  nginx
#  kafka
#  nebula
#  redis
#  hbase
#  hive
#  hdfs
#  yarn
#  prometheus
#  grafana

check_soft=elastic,mysql,nginx,kafka,nebula,redis,mapreduce,spark,livy,hbase,hive,yarn,hdfs,prometheus,grafana

###需要修改配置 end  ###########################################################
# 以下内容禁止修改
. $BIN_DIR/config.ini
. $BIN_DIR/common_function.sh

servers=($(echo $precheck_hosts | tr "," "\n"))

DATE_YMD=`date +%Y%m%d%H%M`
check_result="check_result_$DATE_YMD.log"
log_info "check starting " $check_result

main()
{
  log_info "Execute check yuntu soft install and process starting." $check_result
  soft_list=($(echo $check_soft | tr "," "\n"))
  for (( i = 1; i <= ${#servers[*]}; i++ )); do
		server=${servers[$(($i-1))]}
		for (( j = 1; j <= ${#soft_list[*]}; j++ )); do
      soft_name=${soft_list[$(($j-1))]}
      echo ">>> $server check $soft_name process. command: ps -ef | grep $soft_name | grep -v grep" | tee -a $check_result
      # 检测进程
      ssh $precheck_user@$server " ps -ef | grep $soft_name | grep -v grep " | tee -a $check_result
      # 检测安装情况
      echo ">>> $server check $soft_name rpm is install? command: rpm -qa | grep $soft_name "
      ssh $precheck_user@$server "  rpm -qa | grep $soft_name " | tee -a $check_result
    done
  done

  log_info "Check finished." $check_result
}

##############################################################################
# shellcheck disable=SC2068
main $@
cd $CUR_PATH
##############################################################################