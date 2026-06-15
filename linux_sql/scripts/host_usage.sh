#!/bin/bash

psql_host=$1
psql_port=$2
db_name=$3
psql_user=$4
psql_password=$5

if [ "$#" -ne 5 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

vmstat_mb=$(/usr/bin/vmstat --unit M)
hostname=$(/usr/bin/hostname -f)

memory_free=$(echo "$vmstat_mb" | /usr/bin/awk '{print $4}' | /usr/bin/tail -n1 | /usr/bin/xargs)
cpu_idle=$(echo "$vmstat_mb" | /usr/bin/awk '{print $15}' | /usr/bin/tail -n1 | /usr/bin/xargs)
cpu_kernel=$(echo "$vmstat_mb" | /usr/bin/awk '{print $14}' | /usr/bin/tail -n1 | /usr/bin/xargs)
disk_io=$(/usr/bin/vmstat -d | /usr/bin/awk '{print $10}' | /usr/bin/tail -n1 | /usr/bin/xargs)
disk_available=$(/usr/bin/df -BM / | /usr/bin/tail -n1 | /usr/bin/awk '{print $4}' | /usr/bin/sed 's/M//')
timestamp=$(/usr/bin/vmstat -t | /usr/bin/tail -n1 | /usr/bin/awk '{print $18, $19}')

export PGPASSWORD=$psql_password
host_id=$(/usr/bin/psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -t -c "SELECT id FROM host_info WHERE hostname LIKE 'jrvs-remote-desktop%';" | /usr/bin/xargs)

if [ -z "$host_id" ]; then
    echo "Erreur : Hostname non trouvé"
    exit 1
fi

insert_stmt="INSERT INTO host_usage(timestamp, host_id, memory_free, cpu_idle, cpu_kernel, disk_io, disk_available) VALUES('$timestamp', $host_id, $memory_free, $cpu_idle, $cpu_kernel, $disk_io, $disk_available);"

/usr/bin/psql -h "$psql_host" -p "$psql_port" -d "$db_name" -U "$psql_user" -c "$insert_stmt"

exit $?
