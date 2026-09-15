#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task4_return_codes_error_handling.sh
# @author       Phoebe Alexandra Evans
# @index        7446023
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Runs a sequence of system checks with disciplined
#               exit-code handling and a documented exit scheme.
# @date         2026-09-14
# -----------------------------------------------------------------
#
# Exit codes:
#   0 = all checks passed
#   1 = missing required argument
#   2 = host unreachable
#   3 = insufficient disk space
#   4 = required file not found
#   5 = required command not found
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <hostname>"
  echo "  <hostname>  the host to ping-check as part of the diagnostics"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

HOST="$1"
TEMP_FILE=$(mktemp)

cleanup() {
  rm -f "$TEMP_FILE"
}
trap cleanup EXIT INT TERM

check_status() {
  local RESULT=$1
  local SUCCESS_MSG=$2
  local FAIL_MSG=$3
  local EXIT_CODE=$4

  if [ "$RESULT" -eq 0 ]; then
    echo "PASS: $SUCCESS_MSG"
  else
    echo "FAIL: $FAIL_MSG" >&2
    exit "$EXIT_CODE"
  fi
}
echo "----- Running diagnostic checks on '$HOST' -----"

ping -c 1 -W 2 "$HOST" > /dev/null 2>&1
check_status $? "Host '$HOST' is reachable." "Host '$HOST' is unreachable." 2

AVAILABLE_KB=$(df --output=avail / | tail -n 1 | tr -d ' ')
if [ "$AVAILABLE_KB" -gt 102400 ]; then
  DISK_CHECK=0
else
  DISK_CHECK=1
fi
check_status $DISK_CHECK "Sufficient disk space available." "Insufficient disk space (less than 100MB free)." 3

echo "test data" > "$TEMP_FILE"
[ -f "$TEMP_FILE" ] && [ -r "$TEMP_FILE" ]
check_status $? "Required file '$TEMP_FILE' exists and is readable." "Required file '$TEMP_FILE' not found or unreadable." 4

command -v bash > /dev/null 2>&1
check_status $? "Required command 'bash' is installed." "Required command 'bash' not found." 5

echo "----- All checks passed -----"
echo "Task 4 complete."
exit 0
