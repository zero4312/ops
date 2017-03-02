#!/bin/bash

PID_FILE="/tmp/$(basename $0).pid"

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

ls -lh /tmp/ |grep $PID_FILE
echo "创建了pid文件"
sleep 10

