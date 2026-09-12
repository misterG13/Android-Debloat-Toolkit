# shellcheck shell=bash

# Main menu
mainMenu() {
  local choice=""
  clear
  echo "Main Menu"
  echo "---------"
  echo "1. Debloat"
  echo "2. Restore"
  echo "3. Export Phone's APK List"
  echo "---------"
  echo "4. Reboot Phone"
  echo "5. Exit"
  read -rp "Enter your choice: " choice || { echo ""; exitScript; }

  case $choice in
    1) debloatList ;;
    2) restoreList ;;
    3) apkExport ;;
    4) rebootAndroid ;;
    5) exitScript ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}