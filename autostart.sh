#!/bin/sh

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <add|remove> <command>"
  exit 1
fi

ACTION="$1"
COMMAND="$2"
AUTOSTART_FILE="/etc/xdg/lxsession/LXDE-pi/autostart"

# Convert the second argument (COMMAND) to an absolute path
COMMAND="@lxterminal -e bash $(readlink -f "$COMMAND")"

if [ "$ACTION" != "add" ] && [ "$ACTION" != "remove" ]; then
  echo "Error: First argument must be 'add' or 'remove'."
  exit 1
fi

add_command() {
  if grep -Fxq "$COMMAND" "$AUTOSTART_FILE"; then
    echo "The command is already present in $AUTOSTART_FILE."
  else
    echo "$COMMAND" | sudo tee -a "$AUTOSTART_FILE" > /dev/null
    echo "The command has been added to $AUTOSTART_FILE."
  fi
}

remove_command() {
  if grep -Fxq "$COMMAND" "$AUTOSTART_FILE"; then
    sudo sed -i "\|$COMMAND|d" "$AUTOSTART_FILE"
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

