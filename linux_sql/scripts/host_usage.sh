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
memory_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
cpu_model=$(lscpu | grep "Model name" | cut -d':' -f2 | xargs)
cpu_number=$(lscpu | grep "^CPU(s):" | awk '{print $2}' | head -n1)

insert_stmt="INSERT INTO host_info (hostname, cpu_number, cpu_model, memory_total) VALUES ('$hostname', $cpu_number, '$cpu_model', $memory_total);"

export PGPASSWORD=$psql_password
psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"


exit $?
