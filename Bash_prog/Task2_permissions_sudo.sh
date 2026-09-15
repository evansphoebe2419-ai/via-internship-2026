#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task2_permissions_sudo.sh
# @author       Phoebe Alexandra Evans
# @index        7446023
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Reports and modifies file permissions, demonstrating
#               chmod (numeric/symbolic) and conditional chown.
# @date         2026-09-14
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0 <file-path>"
  echo "  <file-path>  the file whose permissions to inspect/change"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" || -z "$1" ]]; then
  usage
fi

TARGET_FILE="$1"

if [ ! -f "$TARGET_FILE" ]; then
  echo "Error: '$TARGET_FILE' does not exist or is not a regular file." >&2
  exit 1
fi
echo "----- Changing permissions (numeric) -----"
chmod 644 "$TARGET_FILE"
if [ $? -eq 0 ]; then
  echo "Applied numeric permissions 644 (rw-r--r--) to '$TARGET_FILE'."
else
  echo "Error: chmod 644 failed on '$TARGET_FILE'." >&2
  exit 1
fi

echo "----- Changing permissions (symbolic) -----"
chmod u+x "$TARGET_FILE"
if [ $? -eq 0 ]; then
  echo "Applied symbolic permissions u+x (owner execute) to '$TARGET_FILE'."
else
  echo "Error: chmod u+x failed on '$TARGET_FILE'." >&2
  exit 1
fi
echo "----- Checking for root privileges -----"
if [ "$(id -u)" -eq 0 ]; then
  echo "Running as root. Attempting chown to root:root on '$TARGET_FILE'..."
  chown root:root "$TARGET_FILE"
  if [ $? -eq 0 ]; then
    echo "Ownership changed successfully."
  else
    echo "Error: chown failed on '$TARGET_FILE'." >&2
    exit 1
  fi
else
  echo "Not running as root — skipping chown (requires root privileges)."
fi
echo "----- Permissions after changes -----"
SYMBOLIC_PERMS_AFTER=$(stat -c '%A' "$TARGET_FILE")
NUMERIC_PERMS_AFTER=$(stat -c '%a' "$TARGET_FILE")
if [ $? -eq 0 ]; then
  echo "Symbolic: $SYMBOLIC_PERMS_AFTER"
  echo "Numeric:  $NUMERIC_PERMS_AFTER"
else
  echo "Error: failed to read permissions for '$TARGET_FILE'." >&2
  exit 1
fi

echo "Task 2 complete."
exit 0

