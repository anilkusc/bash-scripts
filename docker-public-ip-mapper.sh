#!/bin/bash
ips=($(ip -o -4 addr show ens160 | awk '{print $4}'))
for ((i=0;i<${#ips[@]};i++)); do
   subnet=192.168.$i.0/24
   public_ip=$(echo "${ips[$i]}" | cut -d '/' -f 1)
   bridge_name=custom-bridge-$public_ip
   docker network create --subnet=$subnet --attachable --opt "com.docker.network.bridge.name=$bridge_name" --opt "com.docker.network.bridge.enable_ip_masquerade=false" $bridge_name
   iptables -t nat -A POSTROUTING -s $subnet ! -o $bridge_name -j SNAT --to-source $public_ip
   docker run --rm --network $bridge_name byrnedo/alpine-curl http://www.myip.ch -m 1
done
/sbin/iptables-save
