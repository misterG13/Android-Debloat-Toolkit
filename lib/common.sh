# shellcheck shell=bash

declare -g PROJECT_DIR=${PROJECT_DIR:-$PWD}
declare -g ADB_SERIAL=${ADB_SERIAL:-}

# Run an adb command, targeting ADB_SERIAL when one is explicitly requested.
adb_cmd() {
  if [[ -n $ADB_SERIAL ]]; then
    adb -s "$ADB_SERIAL" "$@"
  else
    adb "$@"
  fi
}

# The connected device's serial, or ADB_SERIAL when explicitly requested.
getSerial() {
  local serial=""

  if [[ -n $ADB_SERIAL ]]; then
    serial=$ADB_SERIAL
  else
    serial=$(adb_cmd get-serialno 2>/dev/null | tr -d '\r')
  fi

  [[ -n $serial ]] || serial="unknown"
  echo "$serial"
}

exitScript() {
  echo ""
  echo "Goodbye!"
  sleep 1 # 1 second
  exit 0 # 0 = successful exit
}

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Error: $1 is required but was not found in PATH."
    exit 1
  }
}

rebootAndroid() {
  local choice=""
  clear
  read -rp "Reboot device now? (Y)es or (N)o " choice
  echo ""

  case ${choice,,} in
    y )
      echo "Rebooting device now..."
      if adb_cmd reboot; then
        exitScript
      else
        echo "Reboot command failed. Check the device connection."
      fi
      ;;
    n ) echo "Not rebooting device." ;;
    * ) echo "Please answer (Y)es or (N)o." ;;
  esac
}

checkDevice() {
  local output
  local target
  local ready_count
  local status_line

  target="$ADB_SERIAL"
  output=$(adb devices 2>/dev/null | tr -d '\r')
  ready_count=$(grep -cE "^[^[:space:]]+[[:space:]]+device$" <<<"$output" || true)

  # A specific device was requested via ADB_SERIAL
  if [[ -n $target ]]; then
    if (( ready_count == 1 )) && grep -qE "^${target}[[:space:]]+device$" <<<"$output"; then
      return 0 # true
    fi
    echo "Error: requested device '$target' (ADB_SERIAL) is not ready."
    return 1 # false
  fi

  # Exactly one authorized, ready device: all good
  if (( ready_count == 1 )); then
    return 0 # true
  fi

  # Multiple ready devices: ambiguous without a serial
  if (( ready_count > 1 )); then
    echo "Error: multiple ready devices detected."
    echo "Set ADB_SERIAL to the serial of the device to target, e.g.:"
    echo "  ADB_SERIAL=<serial> bash android-debloat-toolkit.sh"
    return 1 # false
  fi

  # No ready device: report the most likely cause
  if grep -q "unauthorized" <<<"$output"; then
    echo "Device attached but not authorized. Approve USB debugging on your phone."
  elif grep -q "offline" <<<"$output"; then
    echo "Device attached but offline. Reconnect it and try again."
  elif grep -vqE "List of devices|^$" <<<"$output"; then
    status_line=$(grep -vE "List of devices|^$" <<<"$output" | tr '\n' ' ')
    echo "Device found but not ready: $status_line"
  fi

  return 1 # false
}