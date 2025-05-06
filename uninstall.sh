#!/bin/bash

# Resolve the directory where uninstall.sh is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_FOLDER="$SCRIPT_DIR/Scripts"
INSTALL_DIR="/usr/local/bin"
LOG_FILE="$SCRIPT_DIR/uninstall.log"

# Start logging
echo "Uninstallation started at $(date)" > "$LOG_FILE"

# Check if the scripts folder exists
if [ ! -d "$SCRIPTS_FOLDER" ]; then
  echo "Error: scripts directory not found at $SCRIPTS_FOLDER" | tee -a "$LOG_FILE"
  exit 1
fi

# Uninstall each .sh file
for script in "$SCRIPTS_FOLDER"/*.sh; do
  [ -e "$script" ] || { echo "No .sh files found in $SCRIPTS_FOLDER" | tee -a "$LOG_FILE"; break; }

  filename="$(basename "$script" .sh)"
  target="$INSTALL_DIR/$filename"

  if [ -f "$target" ]; then
    echo "Removing $target" | tee -a "$LOG_FILE"
    sudo rm -f "$target"
  else
    echo "Command $filename not found in $INSTALL_DIR — skipping." | tee -a "$LOG_FILE"
  fi
done

echo "Uninstallation completed at $(date)" | tee -a "$LOG_FILE"