#!/bin/bash
SYSTEM_NAME="Root health monitoring system"
CURRENT_TIME=$(date '+%Y-%m-%d %H-%M-%S')

REPORT=""

get_disk_usage(){
df -h / | awk '$6=="/" {print $5, $6}'
}
get_ram_usage(){
free | awk ' /^Mem:/  {printf "%.2f%%\n", $3/$2*100}'
} 
get_cpu_usage(){
vmstat 1 2 | tail -n 1 | awk '{print 100-$15 "%"}'
}
get_top_processes(){
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
}

build_report(){
DISK_USAGE=$(get_disk_usage)
RAM_USAGE=$(get_ram_usage)
CPU_USAGE=$(get_cpu_usage)
TOP_PROCESSES=$(get_top_processes)

REPORT+="==================================================\n"
REPORT+="System : $SYSTEM_NAME\n"
REPORT+="Time : $CURRENT_TIME\n"
REPORT+="==================================================\n"

REPORT+="Disk Usage : $DISK_USAGE\n"
REPORT+="RAM Usage : $RAM_USAGE\n"
REPORT+="CPU Usage : $CPU_USAGE\n"

REPORT+="==================================================\n"
REPORT+="TOP RUNNING PROCESSES\n"
REPORT+="==================================================\n"

REPORT+="$TOP_PROCESSES\n"
}

print_report(){
echo -e "$REPORT"
}

main(){
build_report
print_report
}

main






