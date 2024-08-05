#!/bin/bash

exitScript() {
  echo ""
  echo "Goodbye!"
  sleep 1 # 1 second
  exit 0 # 0 = successful exit
}

rebootAndroid() {
  clear
  read -p "Reboot device now? (Y)es or (N)o " choice
  echo ""

  case ${choice,,} in
    y ) echo "Rebooting device now..."; adb reboot; exitScript ;;
    n ) echo "Not rebooting device." ;;
    * ) echo "Please answer (Y)es or (N)o." ;;
  esac
}

checkDevice() {
  local output
  output=$(adb devices)

  if echo "$output" | grep -q "List of devices attached"; then
    if echo "$output" | grep -q "^[^ ]\{8,\}[[:space:]]*device$"; then
      return 0 # true
    else
      return 1 # false
    fi
  else
    return 1 # false
  fi
}

loadPackages() {
  local filename="$1"
  declare -g packages # Declare a global variable

  # Skips lines that are blank OR begin with "#"
  # mapfile -t packages < <(grep -v '^[[:space:]]*$\|#' "$filename")

  # Skips lines that are blank
  mapfile -t packages < <(grep -v '^[[:space:]]*$' "$filename")
}

loadJSON() {
  local    file=$1 # JSON file location
  local     key=$2 # JSON variable name
  local  search=$3 # Value to search for in each  $key
  local    key1=$4 # Multiple key and search values
  local search1=$5 # Multiple key and search values

  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    return 1
  fi

  declare -g packages # declare $packages as a global

  # Single key and search value
  # mapfile -t packages < <(jq -r ".[] | select(.\"$key\" == \"$search\") |[.id,.description]" "$file")

  # Multiple key and search values
  mapfile -t packages < <(jq -r ".[] | select((.\"$key\" == \"$search\") and (.\"$key1\" == \"$search1\")) | [.id, .list, .description, .removal] | @tsv" "$file")
}

isPackageInstalled() {
  local package=$1

  # Installed & Disabled
  if adb shell pm list packages -d | grep -q $package; then
    return 1 # false

  # Installed & Enabled
  elif adb shell pm list packages -e | grep -q $package; then
    return 0 # true

  # Not Installed
  else
    return 1 # false
  fi
}

isPackageCached() {
  local package="$1"

  # Installed & Disabled
  if adb shell pm list packages -d | grep -q $package; then
    return 0 # true
  else
    return 1 # false
  fi
}

apkRemoval(){
  local skip=false
  local removalType='d'

  clear
  echo "Begin removing APK files from your Android device."
  echo ""

  read -p "For each APK, do you want to (C)onfirm removal of each, yes to (A)ll or (E)xit? (c/a/e): " confirm
  echo ""

  case ${confirm,,} in
    c) skip=false ;;
    a) skip=true ;;
    e) echo "Removal cancelled."; submenuDebloat ;;
    *) echo "Invalid input. Please enter y, a or c."; submenuDebloat ;;
  esac

  if [[ $skip == true ]]; then
    read -p "For all APKs in this list: (D)isable, (U)ninstall or (C)ancel? (d/u/c): " confirm
    echo ""

    case ${confirm,,} in
      d) removalType='d' ;;
      u) removalType='u' ;;
      c) echo "Removal cancelled."; submenuDebloat ;;
      *) echo "Invalid input. Please enter d, u or c."; submenuDebloat ;;
    esac
  fi

  # Loop through $packages global, set by loadPackages() or loadJSON()
  for package in "${packages[@]}"; do
    apk=$(echo "$package" | cut -f1)
    list=$(echo "$package" | cut -f2)
    description=$(echo "$package" | cut -f3)
    removal=$(echo "$package" | cut -f4)

    # For custom.txt, only echo lines that begin with a '#'
    if [[ $list == '#'* ]]; then
      echo ""
      echo "$apk"
    
    # Check if installed
    else
      if isPackageInstalled $apk; then
        echo ""
        echo "List: $list"
        echo "Removal Type: $removal"
        echo "APK file: $apk"
        echo "Description: $description"
        echo ""

        # Check for 'skip'
        if [[ $skip == false ]]; then
          read -p "(D)isable, (U)ninstall, (S)kip or (E)xit: $apk? (d/u/s/e): " response
          echo ""

        elif [[ $skip == true ]]; then
          response=$removalType
        fi

        # Make response all lowercase
        response=${response,,}

        # Disable APK
        if [[ $response == "d" ]]; then
          adb shell pm disable-user --user 0 $apk
          echo "Disabled: $apk"
          echo ""
          sleep 1
          
        # Uninstall APK
        elif [[ $response == "u" ]]; then
          adb shell pm uninstall --user 0 $apk
          echo "Uninstalled: $apk"
          echo ""
          sleep 1
        
        # Skip APK
        elif [[ $response == "s" ]]; then
          echo "Skipping: $apk"
          sleep 1

        # Exit
        elif [[ $response == "e" ]]; then
          submenuDebloat
        fi

      # Not Installed
      else
        echo "$apk not installed, skipping."
        # sleep 1 # Slow down
      fi
    fi
  done

  echo ""
  read -p "Removal complete, return to (M)ain Menu, (D)ebloat Menu or (E)xit? (m/d/e): " response

  # Make response all lowercase
  response=${response,,}
  
  # (M)ain Menu
  if [[ $response == "m" ]]; then
    mainMenu

  # (D)ebloat Menu
  elif [[ $response == "d" ]]; then
    submenuDebloat
  
  # (E)xit
  elif [[ $response == "e" ]]; then
    exitScript
  
  else
    mainMenu
  fi
}

apkRestore() {
  local skip=false

  clear
  echo "Begin restoring APK files from your Android device."
  echo ""

  read -p "For each APK, do you want to (C)onfirm restoration of each, yes to (A)ll or (E)xit? (c/a/e): " confirm
  echo ""

  # Set $skip variable
  case ${confirm,,} in
    c) skip=false ;;
    a) skip=true ;;
    e) echo "Restore cancelled."; submenuRestore ;;
    *) echo "Invalid input. Please enter c, a or e."; submenuRestore ;;
  esac

  # Loop through $packages global, set by loadPackages() or loadJSON()
  for package in "${packages[@]}"; do
    apk=$(echo "$package" | cut -f1)
    list=$(echo "$package" | cut -f2)
    description=$(echo "$package" | cut -f3)
    removal=$(echo "$package" | cut -f4)

    # For custom.txt, only echo lines that begin with a '#'
    if [[ $list == '#'* ]]; then
      echo ""
      echo "$apk"
    else
      # Check Android cache for $apk
      if isPackageCached $apk; then
        echo ""
        echo "List: $list"
        echo "Removal Type: $removal"
        echo "APK file: $apk"
        echo "Description: $description"
        echo ""

        # Check for 'skip'
        if [[ $skip == false ]]; then
          read -p "(R)estore, (S)kip or (E)xit: $apk? (r/s/e): " response
          echo ""

        elif [[ $skip == true ]]; then
          response="r"
        fi

        # Make response all lowercase
        response=${response,,}

        # Restore APK
        if [[ $response == "r" ]]; then

          # attempt to reinstall
          adb shell pm install-existing --user 0 $apk

          # attempt to enable
          adb shell pm enable --user 0 $apk
          
          # verify $apk was installed and enabled
          if ! isPackageInstalled $apk; then
            echo "Failed to restore $apk."
            echo ""
          else
            echo "Successfully restored $apk."
            echo ""
          fi

        # Skip APK
        elif [[ $response == "s" ]]; then
          echo "Skipping: $apk"
          sleep 1

        # Exit
        elif [[ $response == "e" ]]; then
          submenuRestore
        fi

      # Not Installed
      else
        echo "$apk not disabled, skipping."
      fi
    fi
  done

  echo ""
  read -p "Restoration complete, return to (M)ain Menu, (R)estore Menu or (E)xit? (m/r/e): " response

  # Make response all lowercase
  response=${response,,}
  
  # (M)ain Menu
  if [[ $response == "m" ]]; then
    mainMenu

  # (R)estore Menu
  elif [[ $response == "r" ]]; then
    submenuRestore
  
  # (E)xit
  elif [[ $response == "e" ]]; then
    exitScript

  else
    mainMenu
  fi
}

apkExport() {
  local search_word="$1"
  local file_loc="lists/export/"
  local file_name="apk_list_"
  # local output_file=""
  local packages=($(adb shell pm list packages -f))
  local package_count=${#packages[@]}

  clear

  # Check for search_word with function call
  if [ -z "$search_word" ]; then
    # Ask user for a search term
    read -p "Enter ONE or NO keyword (ex: cn, google, lock, oneplus, oplus, qualcomm, remote, tmo, tmobile): " search_word

    # Make response all lowercase
    search_word=${search_word,,}
  fi

  # ADB shell to get phone's model name
  model_name=$(adb shell getprop ro.product.model)

  # No search word, add model name
  if [[ ! $search_word ]]; then
    # Build output_file
    output_file="${file_loc}${file_name}${model_name}.json"
  else
    # Build output_file
    output_file="${file_loc}${file_name}${model_name}_${search_word}.json"
  fi

  # Creates file or clears file contents
  > $output_file

  echo "Exporting $model_name's APK list to: $output_file"

  # Start JSON format
  echo "[" >> $output_file

  for ((i = 0; i < package_count; i++)); do
    package=${packages[$i]}
    package_path=$(echo $package | cut -d ':' -f 2)
    # package_dir=${package_path%*.apk} # extracts the full directory path
    package_dir=${package_path%.apk=*}  # extracts the directory path
    package_name=${package_path##*.apk=} # extracts the package name
    package_version=$(adb shell dumpsys package $package_name | grep "versionName" | cut -d '=' -f 2)

    # Set package status
    if adb shell pm list packages -d | grep -q $package_name; then
      package_status="disabled"
    elif adb shell pm list packages -e | grep -q $package_name; then
      package_status="enabled"
    else
      package_status="uninstalled"
    fi

    # Export only matching packages
    if [[ $package_name =~ $search_word ]]; then
      # Create description
      package_description="Version: $package_version, Directory: $package_dir"

      echo "  {" >> $output_file
      echo "    \"id\": \"$package_name\"," >> $output_file
      echo "    \"list\": \"unknown\"," >> $output_file
      echo "    \"description\": \"$package_description\"," >> $output_file
      echo "    \"status\": \"$package_status\"," >> $output_file
      echo "    \"removal\": \"unknown\"" >> $output_file
      echo "  }," >> $output_file
    fi
  done

  # End JSON format
  echo "]" >> $output_file

  # Remove last comma
  sed -i '$!N;$s/},/}/' $output_file

  echo ""
  read -p "Export complete, return to (M)ain Menu or (E)xit? (m/e): " response

  # Make response all lowercase
  response=${response,,}
  
  # (M)ain Menu
  if [[ $response == "m" ]]; then
    mainMenu

  # (E)xit
  elif [[ $response == "e" ]]; then
    exitScript

  else
    mainMenu
  fi
}

# Debloat custom.txt
debloatCustom() {
  clear
  loadPackages "lists/custom.txt"
  apkRemoval
}

# Restore custom.txt
restoreCustom() {
  clear
  loadPackages "lists/custom.txt"
  apkRestore
}

# Debloat uad_lists.json
debloatUAD() {
  local choice
  local removal='Recommended'
  local debloat='Google'

  # Ask user what to remove
  echo ""
  read -p "Type in the APK debloat list number you would like to remove: 1-AOSP, 2-Carrier, 3-Google, 4-Misc 5-OEM " debloat_choice

  case $debloat_choice in
    1) debloat="Aosp" ;;
    2) debloat="Carrier" ;;
    3) debloat="Google" ;;
    4) debloat="Misc" ;;
    5) debloat="Oem" ;;
    *) echo "Invalid removal level. Please try again." ;;
  esac

  # Ask user for removal level
  echo ""
  read -p "Type in the removal level number: 1-Recommended, 2-Advanced, 3-Expert, 4-Unsafe " removal_choice

  case $removal_choice in
    1) removal="Recommended" ;;
    2) removal="Advanced" ;;
    3) removal="Expert" ;;
    4) removal="Unsafe" ;;
    *) echo "Invalid removal level. Please try again." ;;
  esac

  loadJSON "lists/uad_lists.json" list $debloat removal $removal
  apkRemoval
}

# Restore uad_lists.json
restoreUAD() {
  local choice
  local removal='Recommended'
  local debloat='Google'

  # Ask user what to remove
  echo ""
  read -p "Type in the APK debloat list number you would like to restore: 1-AOSP, 2-Carrier, 3-Google, 4-Misc 5-OEM " restore_choice

  case $restore_choice in
    1) debloat="Aosp" ;;
    2) debloat="Carrier" ;;
    3) debloat="Google" ;;
    4) debloat="Misc" ;;
    5) debloat="Oem" ;;
    *) echo "Invalid removal level. Please try again." ;;
  esac

  # Ask user for removal level
  echo ""
  read -p "Type in the removal level number: 1-Recommended, 2-Advanced, 3-Expert, 4-Unsafe " removal_choice

  case $removal_choice in
    1) removal="Recommended" ;;
    2) removal="Advanced" ;;
    3) removal="Expert" ;;
    4) removal="Unsafe" ;;
    *) echo "Invalid removal level. Please try again." ;;
  esac

  loadJSON "lists/uad_lists.json" list $debloat removal $removal
  apkRestore
}

# Main menu
mainMenu() {
  clear
  echo "Main Menu"
  echo "---------"
  echo "1. Debloat"
  echo "2. Restore"
  echo "3. Export Phone's APK List"
  echo "---------"
  echo "4. Reboot Phone"
  echo "5. Exit"
  read -p "Enter your choice: " choice

  case $choice in
    1) submenuDebloat ;;
    2) submenuRestore ;;
    3) apkExport ;;
    4) rebootAndroid ;;
    5) exitScript ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}

# Submenu - Debloat
submenuDebloat() {
  clear
  echo "Debloat Submenu"
  echo "--------------"
  echo "1. Custom.txt"
  echo "2. UAD Lists.json"
  echo "3. Back to Main Menu"
  read -p "Enter your choice: " choice

  case $choice in
    1) debloatCustom ;;
    2) debloatUAD ;;
    3) mainMenu ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}

# Submenu - Restore
submenuRestore() {
  clear
  echo "Restore Submenu"
  echo "-------------"
  echo "1. Custom.txt"
  echo "2. UAD Lists.json"
  echo "3. Back to Main Menu"
  read -p "Enter your choice: " choice

  case $choice in
    1) restoreCustom ;;
    2) restoreUAD ;;
    3) mainMenu ;;
    *) echo "Invalid choice. Please try again." ;;
  esac
}

# Check for a connected Android device
if ! checkDevice; then
  clear
  echo "No Android device found."
  echo "Check ADB is running and your phone is connected"
  exitScript
fi

# Start the main menu
while true; do
  mainMenu
done