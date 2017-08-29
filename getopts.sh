#判断输入参数是否为空，不为空则按case语句输出或者执行
#!/bin/bash
if [ ! -n "$1" ];then
  echo "abcdef"
else
while getopts "abc" arg
do
  case $arg in
    a)
    echo "a"
    ;;
    b)
    echo "b"
    ;;
    c)
    echo "c"
    ;;
    ?)
    echo "please ues -a|-b|-c"
    ;;
  esac
done
fi
