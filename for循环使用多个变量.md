shell中
for循环如果想使用多个循环变量
可以使用数组的方式 按数组长度编号循环多个变量 如下例  

```shell
#/bin/bash
a=("xxx" "yyy" "zzz" "fff")
b=("rrr" "ppp" "qqq" "sss")

length=${#a[@]}

for ((i=0;i<=$length;i++)); do
	echo ${a[$1]} ${b[$]}
	done
```
	