#!/bin/bash  
# ./checkweb +URL
export LANG=C

URL="$1"
EMAIL=""    #暂时留空不需要
LOG_FILE="/data/log/shell/`date '+%Y-%m'`check.log"
TMP_EMAIL=""

if [ $2 ]
then
sleep $2
fi

ECHO() {
printf "%s" `date '+%Y-%m-%d_%H:%M:%s'`
echo $1
}

HTTP_CODE() {
http_code=`curl -m 10 -o /dev/null -s -w %{http_code} $URL`
}

RESTART() {
#/usr/bin/systemctl restart php-fpm
echo "shell run normal"
}

n=0
HTTP_CODE
if [ $http_code -eq 200 ]
then
ECHO "|http_code:200|+$n|webpage visit success.|$URL" >> $LOG_FILE
else
while [ $http_code -ne 200 ]
    do
n=`expr $n + 1`
        ECHO "|http_code:$http_code|+$n|webpage visit failed.|$URL" >> $LOG_FILE
        if [ $n -eq 5 ];then
RESTART;exit 0
        fi
sleep 10
        HTTP_CODE
    done
fi

#end
