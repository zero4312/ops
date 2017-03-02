#!/bin/bash
for i in {1..100000};do curl -s -w "%{time_total} %{time_namelookup} %{time_connect} ${time_appconnect} %{time_starttransfer}\n" -o /dev/null -k https://api.taptapdada.com/ --connect-timeout 15; done
