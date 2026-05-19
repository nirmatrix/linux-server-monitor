#!/bin/bash
SYSTEM_NAME="Root health monitoring system"
LOG_FILE="system.log"
DISK_THRESHOLD=80
RAM_THRESHOLD=70
CPU_THRESHOLD=60
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

get_disk_usage(){
df -h / | awk 'NR==2 {gsub("%","",$5); print $5}'
}
get_ram_usage(){
free | awk ' /^Mem:/  {printf "%.0f\n", $3/$2*100}'
}
get_cpu_usage(){
vmstat 1 2 | tail -n 1 | awk '{print 100-$15}'
}
get_top_processes(){
ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -n 6
}

check_status(){

USAGE=$1
THRESHOLD=$2

if (( USAGE >= 95 ));
then
echo "${RED}[CRITICAL]${NC}"
elif (( USAGE >= THRESHOLD ));
then
echo "${YELLOW}[WARNING!]${NC}"
else
echo "${GREEN}[OK]${NC}"
fi
}

build_report(){

CURRENT_TIME=$(date '+%Y-%m-%d %H-%M-%S')
REPORT=""

DISK_USAGE=$(get_disk_usage)
RAM_USAGE=$(get_ram_usage)
CPU_USAGE=$(get_cpu_usage)
TOP_PROCESSES=$(get_top_processes)

DISK_STATUS=$(check_status "$DISK_USAGE" "$DISK_THRESHOLD")
RAM_STATUS=$(check_status "$RAM_USAGE" "$RAM_THRESHOLD")
CPU_STATUS=$(check_status "$CPU_USAGE" "$CPU_THRESHOLD")

REPORT+="==================================================\n"
REPORT+="System : $SYSTEM_NAME\n"
REPORT+="Time : $CURRENT_TIME\n"
REPORT+="==================================================\n"

REPORT+="Disk Usage : ${DISK_USAGE}% $DISK_STATUS\n"
REPORT+="RAM Usage : ${RAM_USAGE}% $RAM_STATUS\n"
REPORT+="CPU Usage : ${CPU_USAGE}% $CPU_STATUS\n"

REPORT+="==================================================\n"
REPORT+="TOP RUNNING PROCESSES\n"
REPORT+="==================================================\n"

REPORT+="$TOP_PROCESSES\n"
}

print_report(){
echo -e "$REPORT"
}

write_log(){
echo -e "$REPORT" >> "$LOG_FILE"
}

main(){
build_report
print_report
write_log
}

main
