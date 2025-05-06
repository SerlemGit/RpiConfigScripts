#!/bin/bash

# Resolve the directory where install.sh is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS_FOLDER="$SCRIPT_DIR/Scripts"
INSTALL_DIR="/usr/local/bin"

# Check if the scripts folder exists
if [ ! -d "$SCRIPTS_FOLDER" ]; then
  echo "Error: scripts directory not found at $SCRIPTS_FOLDER"
  exit 1
fi

# Install each .sh file
for script in "$SCRIPTS_FOLDER"/*.sh; do
  # Skip if no .sh files found
  [ -e "$script" ] || { echo "No .sh files found in $SCRIPTS_FOLDER"; break; }

  # Get filename without path or extension
  filename="$(basename "$script" .sh)"
  target="$INSTALL_DIR/$filename"

  echo "Installing $filename to $INSTALL_DIR"

  # Make the file executable and copy it
  chmod +x "$script"
  sudo cp "$script" "$target"
done

echo "Installation complete."