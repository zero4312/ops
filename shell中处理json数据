shell脚本在处理json数据时经常会报错，特别是json中引用了变量，这种问题大概率是引号的问题，如此处理后可正常调用shell中的变量
server="server1 server2 server3"
'[{"ServerId":"'"${server}"'", "Port":"80", "Weight":"50"}]'
