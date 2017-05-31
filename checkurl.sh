#!/bin/bash
#日志存放位置
LOG=/root/fpmrestart.log
#检测URL
URL=http://bbs.shafa.com
PID_FILE="/tmp/$(basename $0).pid"
检测
function check() {
     count=`curl -I -s --connect-timeout 5 $URL |grep 'HTTP/1.1 200' -c`
	 if [ $count -ne "1" ]; then
       return 0
     else
       return 1
     fi
}
#单例化
function on_startup() {
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

function on_shutdown() {
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

on_startup
check
if 

#if [ $check -ne "1" ]; then
#      echo "##" `date "+%Y-%m-%d %H:%M:%S"` "test one is faild" >> ${LOG}
#      sleep 15
#      /usr/bin/curl -I -s --connect-timeout 5 http://bbs.shafa.com >> ${LOG}
#      sleep 10
#      /usr/bin/systemctl restart php-fpm
#    else
#      echo `date "+%Y-%m-%d %H:%M:%S"` "count is ${count} bbs is normal" >> ${LOG}
#fi

