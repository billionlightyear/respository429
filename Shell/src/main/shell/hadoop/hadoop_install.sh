echo "──────────────────────开始前的准备──────────────────────"

echo "

        oooooo   oooo oooooo   oooooo     oooo
         \`YYY.   .Y'   \`WWW.    \`WWW.     .W'
          \`YYY. .Y'     \`WWW.   .WWWW.   .W'
           \`YYY.Y'       \`WWW  .W'\`WWW. .W'
            \`YYY'         \`WWW.W'  \`WWW.W'
             YYY           \`WWW'    \`WWW'
            oYYYo           \`W'      \`W'

"

echo "
  开始前的准备:
  n台已经配置好静态ip的机器
  n台机器都可以联网

  脚本运行完成后，机器会增加以下东西:java环境、hadoop、Hadoop启动
  停止脚本hadoop-shell、集群分发脚本xsync、免密登录。集群的名字和
  ip需要自行输入，需要在/opt/soft目录下放入以下包：
  hadoop-2.7.6.tar.gz

"
echo "─────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘─────────────"

read -p "准备好了吗？（y/n）" ans

if [ $ans == "n" ]; then
  echo "退出"
  exit
fi

# 一些安装位置
export app_home_dir=/opt/soft
export scripts_home=/opt/bin
export logs_home=/opt/logs
export hadoop_home=${app_home_dir}/hadoop-2.7.6
export hive_home=${app_home_dir}/hive-2.1.1
export hive_conf=${hive_home}/conf
export java_home=${app_home_dir}/jdk1.8.0_221
export sqoop_home=${app_home_dir}/sqoop-1.4.7
export flume_home=${app_home_dir}/flume-1.8.0
export zookeeper_home=${app_home_dir}/zookeeper-3.4.14
export kafka_home=${app_home_dir}/kafka_2.11

echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                开始需要集群机器的名字                │"
echo "│            格式：名字+编号，只需要输入名字           │"
echo "│            例如：young1，只需要输入young             │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"

# 读取名字
read -p "输入集群名字：" cluster_name

read -p "输入多少台集群：" cluster_num

echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                 输入三台集群机器的ip                 │"
echo "│                 格式：192.168.10.131                 │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"

#读取ip
for ((host = 1; host <= ${cluster_num}; host++)); do
  read -p "读取${cluster_name}${host}ip:" ip$host
done

# 常用的脚本
# xsync 分发脚本
cat >${scripts_home}/xsync <<EOF
#!/usr/bin/env bash

pcount=\$#
if((pcount==0)); then
echo no args;
exit;
fi

p1=\$1
fname=\`basename \$p1\`
echo fname=\$fname

pdir=\`cd -P \$(dirname \$p1); pwd\`
echo pdir=\$pdir

user=\`whoami\`

for (( host=1;host<=${cluster_num};host++ )); do
echo ─────────────────── ${cluster_name}\$host ───────────────────
rsync -rvl \$pdir/\$fname \$user@${cluster_name}\$host:\$pdir
done
EOF

chmod 777 ${scripts_home}/xsync

yum install -y wget rsync

# 防火墙永久关闭
systemctl stop firewalld.service
systemctl disable firewalld.service

# 映射文件hosts (ip 机器名) 机器名和ip可以让用户自己输入
for ((i = 1; i <= ${cluster_num}; i++)); do
  eval echo "\$ip${i} ${cluster_name}${i}" >>/etc/hosts
done

for ((host = 1; host <= ${cluster_num}; host++)); do
  echo "┌──────────────────────────────────────────────────────┐"
  echo "│                                                      │"
  echo "│                      安装rsync                       │"
  echo "│                                                      │"
  echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"
  ssh ${cluster_name}${host} "yum -y install rsync; exit"
done

# 免密登录
echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                  配置集群免密登录                    │"
echo "│                     按三次回车                       │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"

ssh-keygen -t rsa
cat /root/.ssh/id_rsa.pub >/root/.ssh/authorized_keys

echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                 免密登录登录测试                     │"
echo "│                   记得输入exit                       │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"
ssh localhost

# 分发.ssh文件
${scripts_home}/xsync /root/.ssh

# java环境
# 下载jdk
# 略
# 配置环境变量
echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                       java环境                       │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"

# 解压jdk
tar -zxvf ${app_home_dir}/jdk-8u221-linux-x64.tar.gz -C ${app_home_dir}

rm -rf ${app_home_dir}/jdk-8u221-linux-x64.tar.gz

echo "
   __ _                         _ __    __
  / /(_)_ __/\_/\__ _ _ __   __| / / /\ \ \\
 / / | | '_ \_ _/ _\` | '_ \ / _\` \ \/  \/ /
/ /__| | | | / \ (_| | | | | (_| |\  /\  /
\____/_|_| |_\_/\__,_|_| |_|\__,_| \/  \/

"

# 下载hadoop-2.7.6.tar.gz文件

echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                     hadoop安装                       │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"

# wget https://archive.apache.org/dist/hadoop/common/hadoop-2.7.6/hadoop-2.7.6.tar.gz

# 解压hadoop-2.7.6.tar.gz文件
tar -zxvf ${app_home_dir}/hadoop-2.7.6.tar.gz -C ${app_home_dir}

rm -rf ${app_home_dir}/hadoop-2.7.6.tar.gz

# 配置hadoop
# 判断集群数量，1台就单机，2台以上分布式
if [ ${cluster_num} == 1 ]; then
  #NameNode所在的机器
  nn=1
  #ResourceManager所在的机器
  Rm=1
  #SecondaryNameNode所在机器
  snn=1
  #JobHistory
  jh=1
  #副本数
  cnm=1
elif [ ${cluster_num} == 2 ]; then
  nn=1
  Rm=2
  snn=1
  jh=2
  cnm=1
else
  nn=1
  Rm=2
  snn=3
  jh=3
  cnm=3
fi

echo "────────────────────────集群配置────────────────────────"
echo
echo "     NameNode:${cluster_name}${nn}"
echo "     ResourceManager:${cluster_name}${Rm}"
echo "     SecondaryNameNode:${cluster_name}${snn}"
echo "     JobHistory:${cluster_name}${jh}"
echo
echo "─────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘─────────────"

# core-site.xml
cat >${hadoop_home}/etc/hadoop/core-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<configuration>
  <!-- 指定HDFS 中NameNode 的地址-->
  <property>
    <name>fs.defaultFS</name>
    <value>hdfs://${cluster_name}${nn}:9000</value>
  </property>

  <!-- 指定Hadoop 运行时产生文件的存储目录-->
  <property>
    <name>hadoop.tmp.dir</name>
    <value>${hadoop_home}/data/tmp</value>
  </property>

  <property>
    <name>hadoop.proxyuser.root.hosts</name>
    <value>*</value>
  </property>

  <property>
    <name>hadoop.proxyuser.root.groups</name>
    <value>*</value>
  </property>
</configuration>
EOF

# hadoop-env.sh
sed -i 's/export JAVA_HOME=\${JAVA_HOME}/export JAVA_HOME=\/opt\/soft\/jdk1.8.0_221/g' ${hadoop_home}/etc/hadoop/hadoop-env.sh

# hdfs-site.xml
cat >${hadoop_home}/etc/hadoop/hdfs-site.xml <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <property>
    <name>dfs.replication</name>
    <value>${cnm}</value>
  </property>
  <!-- 指定Hadoop 辅助名称节点主机配置-->
  <property>
    <name>dfs.namenode.secondary.http-address</name>
    <value>${cluster_name}${snn}:50090</value>
  </property>
</configuration>
EOF

# mapred-site.xml
cat >${hadoop_home}/etc/hadoop/mapred-site.xml <<EOF
<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
  <!-- 指定MR运行在Yarn上-->
  <property>
    <name>mapreduce.framework.name</name>
    <value>yarn</value>
  </property>

  <!-- 历史服务器端地址-->
  <property>
	  <name>mapreduce.jobhistory.address</name>
	  <value>${cluster_name}${jh}:10020</value>
  </property>

  <!-- 历史服务器web 端地址-->
  <property>
    <name>mapreduce.jobhistory.webapp.address</name>
    <value>${cluster_name}${jh}:19888</value>
  </property>

</configuration>
EOF

# mapred-env.sh
echo "export JAVA_HOME=${java_home}" >>${hadoop_home}/etc/hadoop/mapred-env.sh

# yarn-site.xml
cat >${hadoop_home}/etc/hadoop/yarn-site.xml <<EOF
<?xml version="1.0"?>

<configuration>

  <!-- Reducer 获取数据的方式-->
  <property>
    <name>yarn.nodemanager.aux-services</name>
    <value>mapreduce_shuffle</value>
  </property>

  <!-- 指定YARN 的ResourceManager 的地址-->
  <property>
    <name>yarn.resourcemanager.hostname</name>
    <value>${cluster_name}${Rm}</value>
  </property>

  <!-- 日志聚集功能使能-->
  <property>
	  <name>yarn.log-aggregation-enable</name>
	  <value>true</value>
  </property>

  <!-- 日志保留时间设置7 天-->
  <property>
	  <name>yarn.log-aggregation.retain-seconds</name>
	  <value>604800</value>
  </property>

</configuration>
EOF

# yarn-env.sh
sed -i 's/\# export JAVA_HOME=\/home\/y\/libexec\/jdk1.6.0/export JAVA_HOME=\/opt\/soft\/jdk1.8.0_221/g' ${hadoop_home}/etc/hadoop/yarn-env.sh

# slaves
# 清空
cat /dev/null >${hadoop_home}/etc/hadoop/slaves

# 写入节点
for ((i = 1; i <= ${cluster_num}; i++)); do
  echo "${cluster_name}${i}" >>${hadoop_home}/etc/hadoop/slaves
done

# 分发
for i in ${java_home} /etc/hosts ${hadoop_home} /etc/profile.d/env.sh; do
  ${scripts_home}/xsync $i
done

# 启停脚本
cat >${scripts_home}/hadoop-shell <<EOF
#! /bin/bash

pcount=\$#
if((pcount==0)); then
echo no args;
exit;
fi

case \$1 in
start)
	echo "─────────────────── Hadoop启动 ───────────────────"
	echo "─────────────────── hdfs启动 ───────────────────"
	ssh ${cluster_name}${nn} '${hadoop_home}/sbin/start-dfs.sh'
	echo "─────────────────── yarn启动 ───────────────────"
	ssh ${cluster_name}${Rm} '${hadoop_home}/sbin/start-yarn.sh'
	echo "─────────────────── 启动历史服务器 ───────────────────"
	ssh ${cluster_name}${jh} '${hadoop_home}/sbin/mr-jobhistory-daemon.sh start historyserver'
;;
stop)
	echo "─────────────────── Hadoop停止 ───────────────────"
	echo "─────────────────── hdfs停止 ───────────────────"
	ssh ${cluster_name}${nn} '${hadoop_home}/sbin/stop-dfs.sh'
	echo "─────────────────── yarn停止 ───────────────────"
	ssh ${cluster_name}${Rm} '${hadoop_home}/sbin/stop-yarn.sh'
	echo "─────────────────── 停止历史服务器 ───────────────────"
	ssh ${cluster_name}${jh} '${hadoop_home}/sbin/mr-jobhistory-daemon.sh stop historyserver'
;;
esac
EOF

chmod 777 ${scripts_home}/hadoop-shell

echo "┌──────────────────────────────────────────────────────┐"
echo "│                                                      │"
echo "│                     初始化集群                       │"
echo "│                                                      │"
echo "└────────────😀😄😊😋😥😜😝🙃😭😱😡😁😂😍😘────────────┘"
${hadoop_home}/bin/hdfs namenode -format

echo "─────────────────── 启动dfs${cluster_name}${nn} ───────────────────"
ssh ${cluster_name}${nn} '/opt/soft/hadoop-2.7.6/sbin/start-dfs.sh'

echo "─────────────────── 启动yarn${cluster_name}${Rm} ───────────────────"
ssh ${cluster_name}${Rm} '/opt/soft/hadoop-2.7.6/sbin/start-yarn.sh'

echo "─────────────────── 启动历史服务器${cluster_name}${jh} ───────────────────"
ssh ${cluster_name}${jh} '/opt/soft/hadoop-2.7.6/sbin/mr-jobhistory-daemon.sh start historyserver'

#配置环境变量
cat >>/etc/profile.d/env.sh <<EOF
# scripts environment
export SCRIPTS_HOME=${scripts_home}
export PATH=\$PATH:\$SCRIPTS_HOME

# java environment
export JAVA_HOME=${java_home}
export PATH=\$PATH:\$JAVA_HOME/bin

# hadoop environment
export HADOOP_HOME=${hadoop_home}
export PATH=\$PATH:\$HADOOP_HOME/bin:\$HADOOP_HOME/sbin

EOF

source /etc/profile.d/env.sh

# 重新加载环境变量
for ((host = 1; host <= ${cluster_num}; host++)); do
  ssh ${cluster_name}${host} 'source /etc/profile.d/env.sh'
done

# 查看jvm进程
for ((host = 1; host <= ${cluster_num}; host++)); do
  echo "─────────────────── ${cluster_name}${host} ───────────────────"
  ssh ${cluster_name}${host} 'jps'
done
