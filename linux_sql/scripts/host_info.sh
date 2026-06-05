#!/bin/bash

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5


hostname=$(hostname -f)
total_mem=$(vmstat --unit M | tail -1 | awk '{print $4}')
cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
cpu_number=$(lscpu | grep "^CPU(s):" | awk '{print $2}' | head -n1)
cpu_architecture=$(echo "$lscpu_out" | egrep "^Architecture:" | awk '{print $2}' | xargs)
cpu_mhz=$(cat /proc/cpuinfo | grep "cpu MHz" | head -1 | awk '{print $4}')
l2_cache=$(cat /sys/devices/system/cpu/cpu0/cache/index2/size | sed 's/K//')

insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_architecture, cpu_model, cpu_mhz, l2_cache, total_mem) 
VALUES ('$hostname', $cpu_number, '$cpu_architecture', '$cpu_model', $cpu_mhz, $l2_cache, $total_mem);"

export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit $?
