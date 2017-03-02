#!/bin/bash
echo `date` >> ~/test.log
for ((i=1; i<=1000; i++))
do
	echo `date` >> ~/test.log
	echo $i >> ~/test.log
	/usr/bin/curl -w "@curl.txt" -o /dev/null -s  https://www.taptap.com >>~/test.log
done

echo `date` >> ~/test.log
