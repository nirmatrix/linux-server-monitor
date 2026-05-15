#!/bin/bash
system_name="Root health monitoring system"
echo "Start $system_name"
TODAY=$(date '+%Y-%m-%d %H-%M-%S')
echo "$TODAY"
echo "==============================================="
get_disk_info(){
df -h | awk '$6=="/" {print $5, $6}'
}
disk_status=$(get_disk_info)
echo "Disk Usage = $disk_status"
get_ram_info(){
free | awk ' /^Mem:/  {printf "%.2f%%\n", $3/$2*100}'
}
ram_usage=$(get_ram_info)
echo "RAM Usage = $ram_usage" 
get_cpu_info(){
top -bn1 | grep "Cpu(s)" | awk '{print 100-$8 "%"}'
}
cpu_usage=$(get_cpu_info)
echo "CPU Usage = $cpu_usage"
echo "==============================================="
get_process_info(){
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
}

echo "RUNNING PROCESSES"
get_process_info
