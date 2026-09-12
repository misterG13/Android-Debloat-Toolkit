#!/bin/bash

set -u
set -o pipefail

# Abort cleanly if the user interrupts mid-operation
trap 'echo ""; echo "Interrupted by user."; exit 130' INT

# Resolve the project root so the script works from any working directory
PROJECT_DIR=$(CDPATH='' cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

source "$PROJECT_DIR/lib/common.sh"
source "$PROJECT_DIR/lib/lists.sh"
source "$PROJECT_DIR/lib/packages.sh"
source "$PROJECT_DIR/lib/log.sh"
source "$PROJECT_DIR/lib/removal.sh"
source "$PROJECT_DIR/lib/restore.sh"
source "$PROJECT_DIR/lib/export.sh"
source "$PROJECT_DIR/lib/menus.sh"

# Check for required commands
require adb
require jq
require clear

# Check for a connected Android device
if ! checkDevice; then
  clear
  echo "No Android device found."
  echo "Check that ADB is running and your phone is connected."
  echo "If a prompt appears on the phone, allow USB debugging."
  exitScript
fi

# Start the main menu
while true; do
  mainMenu
done