#!/bin/bash

# Récupération des données via lscpu une seule fois
lscpu_out=$(lscpu)

hostname=$(hostname -f)
cpu_number=$(echo "$lscpu_out" | egrep "^CPU\(s\):" | awk '{print $2}' | xargs)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_model=$(echo "$lscpu_out" | egrep "^Model name:" | awk -F ': ' '{print $2}' | xargs)
cpu_mhz=$(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}')
l2_cache=$(cat /sys/devices/system/cpu/cpu0/cache/index2/size | sed 's/K//')
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")
