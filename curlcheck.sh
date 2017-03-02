#!/bin/bash
curl -H "Host:img.taptapdada.com" $1  -k -o /dev/null -w "%{time_total} %{time_namelookup} %{time_connect} ${time_appconnect} %{time_starttransfer}\n"
