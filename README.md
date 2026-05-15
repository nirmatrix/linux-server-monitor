# Linux Server Monitor

A lightweight, automated Bash script designed to monitor system health diagnostics, including Disk usage, RAM statistics, CPU usage, and top running processes. Perfect for DevOps beginners and system administrators.

## 🚀 Features
- **Disk Monitoring:** Tracks percentage usage of the root filesystem.
- **Memory Tracking:** Measures active RAM usage dynamically using optimized `awk`.
- **CPU Metrics:** Captures real-time CPU percentages cleanly via `vmstat` to prevent false positive cron alerts.
- **Process Logging:** Lists the top running processes sorted by performance impact.
- **Automated Logging:** Saves outputs with custom timestamps directly into a local health log file.

## 🛠️ Setup Instructions

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nirmatrix/linux-server-monitor.git
