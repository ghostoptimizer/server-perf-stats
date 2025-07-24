#!/bin/bash
set -euo pipefail

# --- CPU usage function ---
get_cpu_usage(){
  read -r _ u n s i w irq softirq steal rest < /proc/stat
  pre_idle=$(( i + w ))
  pre_tot=$(( u + n + s + i + w + irq + softirq + steal ))
  sleep 1
  read -r _ u n s i w irq softirq steal rest < /proc/stat
  idle2=$(( i + w ))
  tot2=$(( u + n + s + i + w + irq + softirq + steal ))
  diff_idle=$(( idle2 - pre_idle ))
  diff_tot=$(( tot2 - pre_tot ))
  printf "%.1f" "$(bc -l <<< "scale=1; (1 - $diff_idle/$diff_tot)*100")"
}

# --- Argument Parsing ---
MOUNT_POINT="/"
while getopts "m:h" opt; do
  case $opt in
    m) MOUNT_POINT="$OPTARG" ;;
    h) echo "Usage: $0 [-m mount_point]"; exit 0 ;;
    *) exit 1 ;;
  esac
done

echo "==== Server Performance Stats ===="
echo

if [[ -r /proc/stat ]]; then
  cpu_used=$(get_cpu_usage)
  echo "CPU Usage: ${cpu_used}%"
else
  echo "CPU Usage: n/a (no /proc/statthis script needs Linux)"
fi

# --- Memory ---
read total used free shared buff_cache avail <<< \
  $(free -m | awk '/^Mem:/ {print $2, $3, $4, $5, $6, $7}')
mem_pct=$(printf "%.1f" "$(echo "$used/$total*100" | bc -l)")
echo "Memory Usage: ${used}MiB / ${total}MiB (${mem_pct}%)"

# --- Disk ---
read size used_disk avail pct mount <<< \
  $(df -h "$MOUNT_POINT" | awk 'NR==2 {print $2, $3, $4, $5, $6}')
echo "Disk ${mount} Usage: ${used_disk} / ${size} (${pct})"
echo

# --- Top Processes ---
echo "Top 5 processes by CPU:"
ps -eo pid,comm,%cpu --sort=-%cpu | head -n6
echo
echo "Top 5 processes by MEM:"
ps -eo pid,comm,%mem --sort=-%mem | head -n6
echo

# --- Extra Info ---
# OS & Kernel
os_name=$(lsb_release -ds 2>/dev/null || \
           awk -F= '/^PRETTY_NAME/ { print $2 }' /etc/os-release)
echo "OS & Kernel: ${os_name} (kernel $(uname -r))"

# --- Uptime & Load ---
echo "Uptime: $(uptime -p)"
echo -n "Load Average:"
uptime | awk -F'load average:' '{ print $2 }'

# --- Logged-in users ---
echo "Logged-in users: $(who | wc -l)"
