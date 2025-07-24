`server-stats.sh` reports:
- Total CPU usage
- Total memory usage (free vs used, %)
- Total disk usage for a given mount (free vs used, %)
- Top 5 processes by CPU and by memory
- OS & kernel version
- Uptime, load average, and logged-in users

## Usage

```bash
chmod +x server-stats.sh
./server-stats.sh          
./server-stats.sh -m /home 
