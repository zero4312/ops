#!/bin/bash
#阿里云的rds备份文件下载下来后的配置文件需要注销掉
#下面3行
  #innodb_fast_checksum=false
  #innodb_page_size=16384
  #innodb_log_block_size=512
#阿里云数据库恢复至本地数据库脚本
#rds sync
DB="db_name"
DATE=`date +%Y-%m-%d`
YESTERDAY=`date -d last-day +%Y-%m-%d`
DBNAME="${DATE}_market.tar.gz"
DBURL=`/usr/bin/aliyuncli rds DescribeBackups --DBInstanceId $DB --StartTime ${YESTERDAY}T15:00Z --EndTime ${YESTERDAY}T23:00Z | grep BackupDownloadURL | awk '{print $4}'`
PID_FILE="/tmp/$(basename $0).pid"

function show_ok_or_die() {
    if [ $? -eq 0 ]; then
        echo "OK."
    else
        echo "FAILED."
        exit 1
    fi
}

#kill mysql
function killmysql() {
    ps -ef | grep "3308" | grep -v "grep"
    if [ $? -eq 0 ];
    then
        echo "kill mysql"
        kill `ps -ef|grep "3308" | grep -v "grep"|awk '{print $2}'`
    else
        echo "mysql is not running."
    fi
}

#start mysql
function startmysql() {
    /usr/sbin/mysqld --defaults-file=/data/mysql/data/backup-my.cnf --user=mysql --datadir=/data/mysql/data --port=3308 &
}

#restart mysql
function restartmysql() {
   killmysql
   sleep 10
   startmysql
}

#clear old file
function clearoldfile() {
    /usr/bin/rm -rf /data/mysql/data/*
}

#unzip
function unzipnewfile() {
    /root/rds_backup_extract.sh -f /root/$DBNAME -C /data/mysql/data/
}

#recover date
function recover() {
    /usr/bin/innobackupex --defaults-file=/data/mysql/market/backup-my.cnf --apply-log /data/mysql/market && \
    /usr/bin/cp /root/market_backup-my.cnf /data/mysql/data/backup-my.cnf && \
    /usr/bin/chown -R mysql:mysql /data/mysql/data
}

on_startup() {
    # check if pid file already exists
    while [ -f $PID_FILE ]; do
        echo "already running: "$(cat $PID_FILE)", waiting 1 sec..."
        sleep 1
    done
    # if not, touch new pid file
    # but get ready for clean up first
    trap 'on_shutdown' SIGHUP SIGINT SIGTERM ERR EXIT
    echo $$ > $PID_FILE
}

on_shutdown() {
    # remove pid file
  printf "\n"
  printf "Done, removing pid file... "
    rm -f $PID_FILE
    if [ $? -eq 0 ]; then
        echo "OK."
        exit 0
    else
        echo "FAILED."
        exit 1
    fi
}

#init
on_startup

cd /root/

echo "Search mysql and kill."
killmysql
sleep 15

echo "clear old file."
clearoldfile
wait

echo "unzip newfile."
unzipnewfile
wait

echo "recover mysql date."
recover
wait

echo "start mysql"
#启动mysql
startmysql
sleep 15

echo "run mysql command."
#增加Tokudb引擎的支持，并赋予root用户权限
/usr/bin/mysql -uroot --socket=/data/mysql/data/mysql.sock -e "INSTALL SONAME 'ha_tokudb';" && \
/usr/bin/mysql -uroot --socket=/data/mysql/data/mysql.sock -e "grant all privileges on *.* to root@'%' identified by '';" && \
/usr/bin/mysql -uroot --socket=/data/mysql/data/mysql.sock -e "flush privileges;"
sleep 10

#修改默认存储引擎为TokuDB
echo default-storage-engine=TokuDB >> /data/mysql/data/backup-my.cnf && \
echo innodb_buffer_pool_size=2048M >> /data/mysql/data/backup-my.cnf
sleep 5
restartmysql
sleep 5
/usr/bin/mysql -uroot --socket=/data/mysql/data/mysql.sock -e "show engines;" |grep DEFAULT
echo "recover finish."

