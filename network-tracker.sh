#!/bin/bash

addresses=( www.google.com www.doesntreach.com )
#latency treshold.If pong > 3 this is a big number for me on local network.
treshold=3


for address in "${addresses[@]}"
do

    time=$( ping -c 1 $address  | head -n 2 | tail -n 1 )

    if [[ $time == "" ]];then
        echo "$(date)   NO ANSWER FROM $address" >> logs.txt    
        continue
    else
        sleep 0.1
    fi    

    latency=$( echo $time | awk '{print $7}' | sed 's/time=//' | sed 's/\..*//' )

    if [[ $latency -gt $treshold ]];then
        echo $(date) "  " $time >> logs.txt    
    else
        sleep 0.1
    fi
done
