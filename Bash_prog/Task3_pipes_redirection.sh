#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task3_pipes_redirection.sh
# @author       Phoebe Alexandra Evans
# @index        7446023
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Generates sample log data, then uses pipes and text
#               tools to summarize it: line counts, level counts,
#               top IPs, and all ERROR lines.
# @date         2026-09-14
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  (no arguments needed — this script generates its own log data)"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi
LOG_FILE="sample.log"

cat > "$LOG_FILE" << 'EOF'
2026-09-11 10:00:01 INFO 192.168.1.10 User login successful
2026-09-11 10:00:15 INFO 192.168.1.11 User login successful
2026-09-11 10:00:32 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:00:47 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:02 INFO 192.168.1.12 User login successful
2026-09-11 10:01:19 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:01:35 INFO 192.168.1.10 File uploaded successfully
2026-09-11 10:01:50 WARN 192.168.1.15 Memory usage above 75%
2026-09-11 10:02:06 INFO 192.168.1.11 User logout
2026-09-11 10:02:21 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:02:38 INFO 192.168.1.12 User login successful
2026-09-11 10:02:54 INFO 192.168.1.10 File downloaded
2026-09-11 10:03:10 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:03:25 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:03:41 INFO 192.168.1.13 User login successful
2026-09-11 10:03:58 INFO 192.168.1.11 File uploaded successfully
2026-09-11 10:04:14 WARN 192.168.1.15 Memory usage above 75%
2026-09-11 10:04:30 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:04:47 INFO 192.168.1.12 User logout
2026-09-11 10:05:03 INFO 192.168.1.10 User login successful
2026-09-11 10:05:19 WARN 192.168.1.10 CPU usage above 90%
2026-09-11 10:05:36 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:05:52 INFO 192.168.1.14 User login successful
2026-09-11 10:06:08 INFO 192.168.1.11 File downloaded
2026-09-11 10:06:24 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:06:41 INFO 192.168.1.10 User logout
2026-09-11 10:06:57 WARN 192.168.1.15 Memory usage above 75%
2026-09-11 10:07:13 INFO 192.168.1.12 User login successful
2026-09-11 10:07:29 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:07:46 INFO 192.168.1.13 File uploaded successfully
2026-09-11 10:08:02 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:08:18 INFO 192.168.1.11 User login successful
2026-09-11 10:08:35 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:08:51 INFO 192.168.1.14 User logout
2026-09-11 10:09:07 INFO 192.168.1.10 File downloaded
2026-09-11 10:09:24 WARN 192.168.1.15 Memory usage above 75%
2026-09-11 10:09:40 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:09:56 INFO 192.168.1.12 User login successful
2026-09-11 10:10:13 INFO 192.168.1.11 File uploaded successfully
2026-09-11 10:10:29 WARN 192.168.1.10 CPU usage above 90%
2026-09-11 10:10:45 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:11:02 INFO 192.168.1.13 User login successful
2026-09-11 10:11:18 INFO 192.168.1.14 User logout
2026-09-11 10:11:34 WARN 192.168.1.15 Memory usage above 75%
2026-09-11 10:11:51 ERROR 192.168.1.23 Connection timeout
2026-09-11 10:12:07 INFO 192.168.1.10 File downloaded
2026-09-11 10:12:23 INFO 192.168.1.11 User login successful
2026-09-11 10:12:40 WARN 192.168.1.10 Disk usage above 80%
2026-09-11 10:12:56 ERROR 192.168.1.30 Database connection failed
2026-09-11 10:13:12 INFO 192.168.1.12 User logout
2026-09-11 10:13:29 INFO 192.168.1.14 User login successful
EOF

if [ $? -eq 0 ]; then
  echo "Sample log data written to '$LOG_FILE' (50 lines)."
else
  echo "Error: failed to generate log data." >&2
  exit 1
fi
RESULTS_FILE="results.txt"
ERROR_LOG="errors.log"

{
  echo "----- Log Summary Report -----"

  TOTAL_LINES=$(wc -l < "$LOG_FILE")
  echo "Total lines: $TOTAL_LINES"

  echo ""
  echo "Lines per log level:"
  awk '{print $3}' "$LOG_FILE" | sort | uniq -c | sort -rn

  echo ""
  echo "Top 3 most frequent IP addresses:"
  awk '{print $4}' "$LOG_FILE" | sort | uniq -c | sort -rn | head -n 3

  echo ""
  echo "All ERROR lines:"
  grep "ERROR" "$LOG_FILE"

} > "$RESULTS_FILE" 2> "$ERROR_LOG"

if [ $? -eq 0 ]; then
  echo "Report written to '$RESULTS_FILE'. Any errors captured in '$ERROR_LOG'."
else
  echo "Error: failed to generate the report." >&2
  exit 1
fi

echo "Task 3 complete."
exit 0
