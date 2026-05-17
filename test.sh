#!/bin/bash
SYSTEM_NAME="Root health monitoring system"
CURRENT_TIME=$(date '+%Y-%m-%d %H-%M-%S')
DISK_THRESHOLD=80

REPORT=""

get_disk_usage(){
df -h / | awk 'NR==2 {gsub("%","",$5); print $5}'
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

check_disk_threshold(){

DISK_STATUS=$(get_disk_usage)

if (( DISK_STATUS > DISK_THRESHOLD ));
then
echo "WARNING Disk usage above ${DISK_THRESHOLD}%"
else
echo "${DISK_STATUS}%"
fi
}

build_report(){
DISK_USAGE=$(check_disk_threshold)
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

write_log(){
echo -e "$REPORT" >> system.log
}

main(){
build_report
print_report
write_log
}

main
