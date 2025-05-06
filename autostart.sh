#!/bin/bash

# Check arguments
if [ "$#" -ne 2 ]; then
  echo "Usage: $0 /path/to/executable EntryName"
  exit 1
fi

INPUT_PATH="$1"
ENTRY_NAME="$2"
AUTOSTART_DIR="$HOME/.config/autostart"
DESKTOP_FILE="$AUTOSTART_DIR/${ENTRY_NAME}.desktop"

# Resolve full path
EXECUTABLE_PATH="$(realpath "$INPUT_PATH" 2>/dev/null)"

# Validate resolved path
if [ ! -x "$EXECUTABLE_PATH" ]; then
  echo "Error: '$INPUT_PATH' is not a valid executable file."
  exit 2
fi

# Create autostart directory if needed
mkdir -p "$AUTOSTART_DIR"

# Create desktop file
if [ ! -f "$DESKTOP_FILE" ]; then
  cat <<EOF > "$DESKTOP_FILE"
[Desktop Entry]
Type=Application
Name=$ENTRY_NAME
Exec=$EXECUTABLE_PATH
X-GNOME-Autostart-enabled=true
EOF
  chmod +x "$DESKTOP_FILE"
  echo "Autostart entry created at: $DESKTOP_FILE"
else
  echo "Autostart entry already exists: $DESKTOP_FILE"
fi