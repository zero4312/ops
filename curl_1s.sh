#!/bin/bash
for i in {1..10000};do 
curl -k -I https://assets.taptapdada.com/style/base.css; 
sleep 1s
done
