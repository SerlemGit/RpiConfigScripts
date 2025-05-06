#!/bin/bash

if [ "$#" -lt 1 ]; then
    echo "Usage: $0 <Install|Uninstall> [<cores_to_isolate> | <cores_to_remove>]"
    echo "Example for Install: $0 Install 1,2,3"
    echo "Example for Uninstall: $0 Uninstall 1,2"
    exit 1
fi

ACTION="$1"
CMDLINE_FILE="/boot/cmdline.txt"

install_isolation() {
    if [ "$#" -ne 1 ]; then
        echo "Usage for Install: $0 Install <cores_to_isolate>"
        exit 1
    fi

    CORES_TO_ISOLATE="$1"

    # Check if isolcpus is already set and get the current isolated cores
    CURRENT_ISOLCPUS=$(grep -oP 'isolcpus=\K[^ ]*' "$CMDLINE_FILE")
    
    # If isolcpus is not set, initialize it
    if [ -z "$CURRENT_ISOLCPUS" ]; then
        echo "Appending isolcpus and nohz_full to /boot/cmdline.txt..."
        ISOLCPUS="isolcpus=$CORES_TO_ISOLATE nohz_full=$CORES_TO_ISOLATE"
        sudo sed -i "s/$/ $ISOLCPUS/" "$CMDLINE_FILE"
        echo "Cores $CORES_TO_ISOLATE are now isolated in /boot/cmdline.txt."
        return
    fi

    # Convert current isolated cores to an array
    IFS=',' read -r -a CURRENT_CORES <<< "$CURRENT_ISOLCPUS"

    # Combine existing and new cores while avoiding duplicates
    for CORE in $(echo "$CORES_TO_ISOLATE" | tr ',' ' '); do
        if ! [[ " ${CURRENT_CORES[*]} " =~ " $CORE " ]]; then
            CURRENT_CORES+=("$CORE")
        fi
    done

    # Construct new isolcpus and nohz_full values
    NEW_ISOLCPUS=$(IFS=,; echo "${CURRENT_CORES[*]}")
    
    # Update cmdline.txt
    echo "Updating isolcpus and nohz_full in /boot/cmdline.txt..."
    sudo sed -i "s/isolcpus=[^ ]*/isolcpus=$NEW_ISOLCPUS/; s/nohz_full=[^ ]*/nohz_full=$NEW_ISOLCPUS/" "$CMDLINE_FILE"

    echo "Cores $NEW_ISOLCPUS are now isolated in /boot/cmdline.txt."

    # Reboot prompt
    echo -e "\nStep 2: Reboot is required to apply core isolation."
    read -p "Do you want to reboot now? [y/N]: " REBOOT
    if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
        echo "Rebooting now..."
        sudo reboot
    else
        echo "Reboot manually later to apply core isolation."
    fi
}

uninstall_isolation() {
    if [ "$#" -ne 1 ]; then
        echo "Usage for Uninstall: $0 Uninstall <cores_to_remove>"
        exit 1
    fi

    CORES_TO_REMOVE="$1"
    sudo cp "$CMDLINE_FILE" "${CMDLINE_FILE}.bak"

    # Check if isolcpus is set for any cores to be removed
    if ! grep -q "isolcpus=" "$CMDLINE_FILE"; then
        echo "No core isolation settings found in /boot/cmdline.txt."
        return
    fi

    CURRENT_ISOLCPUS=$(grep -oP 'isolcpus=\K[^ ]*' "$CMDLINE_FILE")
    
    # Convert the current isolcpus to an array
    IFS=',' read -r -a CURRENT_CORES <<< "$CURRENT_ISOLCPUS"

    # Create a new array excluding the cores to remove
    NEW_CORES=()
    for CORE in "${CURRENT_CORES[@]}"; do
        if ! [[ "$CORES_TO_REMOVE" =~ (^|,)${CORE}(,|$) ]]; then
            NEW_CORES+=("$CORE")
        fi
    done

    # Construct the new isolcpus and nohz_full values
    if [ ${#NEW_CORES[@]} -eq 0 ]; then
        echo "All cores have been removed from isolation. Removing isolcpus entirely."
        sudo sed -i 's/ isolcpus=[^ ]*//; s/nohz_full=[^ ]*//; s/  */ /g; s/^ //; s/ $//' "$CMDLINE_FILE"
    else
        NEW_ISOLCPUS=$(IFS=,; echo "${NEW_CORES[*]}")
        echo "Updating isolcpus and nohz_full in /boot/cmdline.txt..."
        sudo sed -i "s/isolcpus=[^ ]*/isolcpus=$NEW_ISOLCPUS/; s/nohz_full=[^ ]*/nohz_full=$NEW_ISOLCPUS/" "$CMDLINE_FILE"
    fi

    # Clean up extra spaces
    sudo sed -i 's/  */ /g; s/^ //; s/ $//' "$CMDLINE_FILE"

    echo "Cores $CORES_TO_REMOVE have been removed from isolation in /boot/cmdline.txt."

    # Reboot prompt
    echo -e "\nReboot is required to apply the changes."
    read -p "Do you want to reboot now? [y/N]: " REBOOT
    if [[ "$REBOOT" =~ ^[Yy]$ ]]; then
        echo "Rebooting now..."
        sudo reboot
    else
        echo "Reboot manually later to apply the changes."
    fi
}

case "$ACTION" in
    Install)
        install_isolation "$2"
        ;;
    Uninstall)
        uninstall_isolation "$2"
        ;;
    *)
        echo "Invalid action. Use Install or Uninstall."
        exit 1
        ;;
esac

echo "Setup complete."
