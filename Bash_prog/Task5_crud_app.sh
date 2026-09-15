#!/usr/bin/env bash
# -----------------------------------------------------------------
# @title        Task5_crud_app.sh
# @author       Phoebe Alexandra Evans
# @index        7446023
# @school       Kwame Nkrumah University of Science and Technology (KNUST)
# @description  Menu-driven CRUD todo list app storing data in a
#               CSV file: add, view, search, update, delete tasks.
# @date         2026-09-14
# -----------------------------------------------------------------

usage() {
  echo "Usage: $0"
  echo "  (no arguments needed — run the script and use the on-screen menu)"
  exit 1
}

if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  usage
fi

DATA_FILE="todo.csv"
BACKUP_FILE="todo.csv.bak"

if [ ! -f "$DATA_FILE" ]; then
  touch "$DATA_FILE"
  echo "Created new data file '$DATA_FILE'."
fi
backup_data() {
  cp "$DATA_FILE" "$BACKUP_FILE"
}

add_task() {
  echo "----- Add a new task -----"
  read -p "Task description: " DESC
  if [ -z "$DESC" ]; then
    echo "Error: description cannot be empty." >&2
    return 1
  fi

  read -p "Due date (optional, e.g. 2026-09-20, or leave blank): " DUE

  NEW_ID=$(($(wc -l < "$DATA_FILE") + 1))
  echo "$NEW_ID,$DESC,pending,$DUE" >> "$DATA_FILE"
  echo "Task added with ID $NEW_ID."
}
view_tasks() {
  echo "----- All tasks -----"
  if [ ! -s "$DATA_FILE" ]; then
    echo "No tasks found."
    return
  fi
  echo "ID | Description | Status | Due Date"
  while IFS=, read -r ID DESC STATUS DUE; do
    echo "$ID | $DESC | $STATUS | $DUE"
  done < "$DATA_FILE"
}

search_tasks() {
  echo "----- Search tasks -----"
  read -p "Enter a keyword to search for: " KEYWORD
  if [ -z "$KEYWORD" ]; then
    echo "Error: search keyword cannot be empty." >&2
    return 1
  fi

  MATCHES=$(grep -i "$KEYWORD" "$DATA_FILE")
  if [ -z "$MATCHES" ]; then
    echo "No matching tasks found for '$KEYWORD'."
  else
    echo "ID | Description | Status | Due Date"
    echo "$MATCHES" | while IFS=, read -r ID DESC STATUS DUE; do
      echo "$ID | $DESC | $STATUS | $DUE"
    done
  fi
}
update_task() {
  echo "----- Update a task -----"
  read -p "Enter the ID of the task to update: " ID
  if [ -z "$ID" ]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^$ID," "$DATA_FILE"; then
    echo "Task with ID $ID not found."
    return 1
  fi

  read -p "New description (leave blank to keep unchanged): " NEW_DESC
  read -p "New status (pending/done, leave blank to keep unchanged): " NEW_STATUS
  read -p "New due date (leave blank to keep unchanged): " NEW_DUE

  backup_data

  OLD_LINE=$(grep "^$ID," "$DATA_FILE")
  IFS=, read -r OLD_ID OLD_DESC OLD_STATUS OLD_DUE <<< "$OLD_LINE"

  [ -n "$NEW_DESC" ] && OLD_DESC="$NEW_DESC"
  [ -n "$NEW_STATUS" ] && OLD_STATUS="$NEW_STATUS"
  [ -n "$NEW_DUE" ] && OLD_DUE="$NEW_DUE"

  sed -i "s/^$ID,.*/$ID,$OLD_DESC,$OLD_STATUS,$OLD_DUE/" "$DATA_FILE"
  echo "Task $ID updated (backup saved to '$BACKUP_FILE')."
}

delete_task() {
  echo "----- Delete a task -----"
  read -p "Enter the ID of the task to delete: " ID
  if [ -z "$ID" ]; then
    echo "Error: ID cannot be empty." >&2
    return 1
  fi

  if ! grep -q "^$ID," "$DATA_FILE"; then
    echo "Task with ID $ID not found."
    return 1
  fi

  read -p "Are you sure you want to delete task $ID? (y/n): " CONFIRM
  if [ "$CONFIRM" != "y" ]; then
    echo "Delete cancelled."
    return
  fi

  backup_data
  sed -i "/^$ID,/d" "$DATA_FILE"
  echo "Task $ID deleted (backup saved to '$BACKUP_FILE')."
}
while true; do
  echo ""
  echo "===== Todo List Menu ====="
  echo "1) Add task"
  echo "2) View/List tasks"
  echo "3) Search tasks"
  echo "4) Update task"
  echo "5) Delete task"
  echo "6) Exit"
  read -p "Choose an option (1-6): " CHOICE

  case "$CHOICE" in
    1) add_task ;;
    2) view_tasks ;;
    3) search_tasks ;;
    4) update_task ;;
    5) delete_task ;;
    6)
      echo "Goodbye."
      exit 0
      ;;
    *)
      echo "Invalid option. Please choose a number from 1 to 6." >&2
      ;;
  esac
done
