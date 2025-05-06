#!/bin/sh

sudo apt update
sudo apt install libunwind-dev libnfc-dev           # For the unwind library, allowing us to print clear call stack after a crash
sudo apt install libunwind-devel libnfc-devel       # For the NFC library, allowing us to use NFC card readers.