#!/bin/bash

# Récupération des données dynamiques
timestamp=$(date -u +"%Y-%m-%d %H:%M:%S")
memory_free=$(vmstat --unit M | tail -1 | awk '{print $4}')
cpu_idle=$(vmstat --unit M | tail -1 | awk '{print $15}')
cpu_kernel=$(vmstat --unit M | tail -1 | awk '{print $14}')
disk_io=$(vmstat --unit M -d | tail -1 | awk '{print $10}')
disk_available=$(df -BM / | tail -1 | awk '{print $4}' | sed 's/M//')
