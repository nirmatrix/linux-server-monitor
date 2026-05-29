#!/bin/bash
source config.conf

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
get_log_size(){
stat -c%s "$LOG_FILE"
} 

evaluate_system_health(){
if [[ "$DISK_STATUS" == *"CRITICAL"* || "$CPU_STATUS" == *"CRITICAL"* || "$RAM_STATUS" == *"CRITICAL"* ]]
then
SYSTEM_STATUS="${RED}[CRITICAL]${NC}"
elif [[ "$DISK_STATUS" == *"WARNING"* || "$CPU_STATUS" == *"WARNING"* || "$RAM_STATUS" == *"WARNING"* ]]
then
SYSTEM_STATUS="${YELLOW}[WARNING!]${NC}"
else
SYSTEM_STATUS="${GREEN}[OK]${NC}" 
fi
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
SYSTEM_STATUS=""
REPORT=""

DISK_USAGE=$(get_disk_usage)
RAM_USAGE=$(get_ram_usage)
CPU_USAGE=$(get_cpu_usage)
TOP_PROCESSES=$(get_top_processes)

DISK_STATUS=$(check_status "$DISK_USAGE" "$DISK_THRESHOLD")
RAM_STATUS=$(check_status "$RAM_USAGE" "$RAM_THRESHOLD")
CPU_STATUS=$(check_status "$CPU_USAGE" "$CPU_THRESHOLD")

evaluate_system_health

REPORT+="==================================================\n"
REPORT+="System : $SYSTEM_NAME\n"
REPORT+="Time : $CURRENT_TIME\n"
REPORT+="==================================================\n"

REPORT+="Disk Usage : ${DISK_USAGE}% $DISK_STATUS\n"
REPORT+="RAM Usage : ${RAM_USAGE}% $RAM_STATUS\n"
REPORT+="CPU Usage : ${CPU_USAGE}% $CPU_STATUS\n"
REPORT+="OVERALL STATUS : $SYSTEM_STATUS\n"

REPORT+="==================================================\n"
REPORT+="TOP RUNNING PROCESSES\n"
REPORT+="==================================================\n"

REPORT+="$TOP_PROCESSES\n"
}

trigger_alert(){
if [[ "$SYSTEM_STATUS" == *"WARNING"* ]]
then
REPORT+="==================================================\n"
REPORT+="${RED}ALERT : Immediate attention required${NC}\n"
REPORT+="==================================================\n"
fi
}

rotate_log(){
if [[ -f "$LOG_FILE" ]];
then
LOG_SIZE=$(get_log_size)

	if (( LOG_SIZE > MAX_LOG_SIZE ));
	then
	mv "$LOG_FILE" "${LOG_FILE}.old"
	fi
fi
}

write_log(){
echo -e "$REPORT" >> "$LOG_FILE"
}

print_report(){
echo -e "$REPORT"
}

main(){
build_report
trigger_alert
rotate_log
write_log
print_report

if [[ "$SYSTEM_STATUS" == *"CRITICAL"* ]]
then
	exit 1
else
	exit 0
fi
}

main
