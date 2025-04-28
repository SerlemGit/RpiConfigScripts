#!/bin/sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <add|remove> <command>"
  exit 1
fi

ACTION="$1"
COMMAND="$2"
AUTOSTART_FILE="/etc/xdg/lxsession/LXDE-pi/autostart"

# Prepare the command depending if it's a file
if [ -f "$COMMAND" ]; then
  # It's a file; build cd and execute
  COMMAND_ABS="$(readlink -f "$COMMAND")"
  COMMAND_DIR="$(dirname "$COMMAND_ABS")"
  COMMAND_FILE="$(basename "$COMMAND_ABS")"
  COMMAND_TO_WRITE="@lxterminal -e bash -c cd \"$COMMAND_DIR\" && ./$COMMAND_FILE"
else
  # It's a regular command; leave it
  COMMAND_TO_WRITE="@lxterminal -e bash \"$COMMAND\""
fi

if [ "$ACTION" != "add" ] && [ "$ACTION" != "remove" ]; then
  echo "Error: First argument must be 'add' or 'remove'."
  exit 1
fi

add_command() {
  if grep -Fxq "$COMMAND_TO_WRITE" "$AUTOSTART_FILE"; then
    echo "The command is already present in $AUTOSTART_FILE."
  else
    echo "$COMMAND_TO_WRITE" | sudo tee -a "$AUTOSTART_FILE" > /dev/null
    echo "The command has been added to $AUTOSTART_FILE."
  fi
}

remove_command() {
  if grep -Fxq "$COMMAND_TO_WRITE" "$AUTOSTART_FILE"; then
    sudo sed -i "\|$COMMAND_TO_WRITE|d" "$AUTOSTART_FILE"
    echo "The command has been removed from $AUTOSTART_FILE."
  else
    echo "The command was not found in $AUTOSTART_FILE."
  fi
}

if [ "$ACTION" = "add" ]; then
  add_command
elif [ "$ACTION" = "remove" ]; then
  remove_command
fi
