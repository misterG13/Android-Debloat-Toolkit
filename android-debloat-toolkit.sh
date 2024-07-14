#!/bin/bash

menuExit() {
  echo "Goodbye!"
  sleep 1
  exit 0
}

rebootAndroid() {
  # add user confirmation to reboot
  adb reboot
  menuExit
}

checkDevice() {
  local output
  output=$(adb devices)
  if echo "$output" | grep -q "List of devices attached"; then
    if echo "$output" | grep -q "^[^ ]\{8,\}[[:space:]]*device$"; then
      return 0
    else
      return 1
    fi
  else
    return 1
  fi
}

loadPackages() {
  local filename="$1"

  declare -g packages # declare $packages as a global

  # mapfile -t packages < <(grep -v '^[[:space:]]*$\|#' "$filename") # skip lines that are blank or begin with "#"
  mapfile -t packages < <(grep -v '^[[:space:]]*$' "$filename") # skip lines that are blank

  # for package in "${packages[@]}"; do
  #   echo "Package: $package"
  # done
}

loadJSON() {
  local file=$1   # JSON file location
  local key=$2    # JSON variable name
  local search=$3 # Value of the $key
  # Multiple search
  local key1=$4
  local search1=$5

  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    return 1
  fi

  declare -g packages # declare $packages as a global

  # Single key and search value
  # mapfile -t packages < <(jq -r ".[] | select(.\"$key\" == \"$search\") |[.id,.description]" "$file")

  # Multiple key and search values
  # mapfile -t packages < <(jq -r ".[] | select((.\"$key\" == \"$search\") and (.\"$key1\" == \"$search1\")) | [.id, .description]" "$file")
  # mapfile -t packages < <(jq -r ".[] | select(.\"$key\" == \"$search\") | [.id, .description] | @tsv" "$file")
  mapfile -t packages < <(jq -r ".[] | select((.\"$key\" == \"$search\") and (.\"$key1\" == \"$search1\")) | [.id, .list, .description, .removal] | @tsv" "$file")
  
  # Print out the extracted key and data
  # echo "Extracted data:"
  # for package in "${packages[@]}"; do
  #   echo "  Key: $key, Value: $package"
  # done

  # for package in "${packages[@]}"; do
  #   apk=$(echo "$package" | cut -f1)
  #   list=$(echo "$package" | cut -f2)
  #   description=$(echo "$package" | cut -f3)
  #   removal=$(echo "$package" | cut -f4)

  #   echo "List: $list"
  #   echo "Removal Type: $removal"
  #   echo "APK file: $apk"
  #   echo "Description: $description"
  #   echo ""
  # done
}

saveJSON(){
  declare -A arr
  arr["name"]="John"
  arr["age"]=30
  arr["city"]="New York"

  jq -n --argjson arr "$(declare -p arr | sed '/declare -A //')" '.[]' > output.json
}

isPackageInstalled() {
  local package=$1

  # Installed & disabled
  if adb shell pm list packages -d | grep -q $package; then
    echo "$package is disabled."
    # false
    return 1

  # Installed & enabled
  elif adb shell pm list packages -e | grep -q $package; then
    # true
    return 0

  # Not installed
  else
    echo "$package is not installed."
    # false
    return 1
  fi
}

isPackageCached() {
  local package_name="$1"
  local output=$(adb shell pm list packages -u | grep -c $package_name)

  if [ $output -eq 0 ]; then
    # false
    return 1
  else
    # true
    return 0
  fi
}

apkDisable() {
  local skip=false

  # 'skip' bypasses the ask to remove/disable input
  if [ "$1" = "skip" ]; then
    skip=true
  fi

  # ---

  for package in "${packages[@]}"; do
    apk=$(echo "$package" | cut -f1)
    list=$(echo "$package" | cut -f2)
    description=$(echo "$package" | cut -f3)
    removal=$(echo "$package" | cut -f4)

    # Check if installed
    if [[ ${package:0:1} == "#" ]]; then
      echo ""
      echo "$package"
    elif isPackageInstalled $apk; then
      echo "List: $list"
      echo "Removal Type: $removal"
      echo "APK file: $apk"
      echo "Description: $description"
      echo ""

      # Check for 'skip'
      if [[ $skip == false ]]; then
        read -p "Disable $apk? (y/n): " response
      elif [[ $skip == true ]]; then
        response="y"
      fi

      # Disable APK
      if [[ $response == "y" ]]; then
        adb shell pm disable-user --user 0 $apk
        echo "Disabled $apk"
      fi
    fi

    # echo "List: $list"
    # echo "Removal Type: $removal"
    # echo "APK file: $apk"
    # echo "Description: $description"
    # echo ""
  done

  # ---

  # for package in "${packages[@]}"; do
  #   if [[ ${package:0:1} == "#" ]]; then
  #     echo ""
  #     echo "$package"
  #   elif isPackageInstalled $package; then
  #     if [[ $skip == false ]]; then
  #       read -p "Disable $package? (y/n): " response
  #     elif [[ $skip == true ]]; then
  #       response="y"
  #     fi
  #     if [[ $response == "y" ]]; then
  #       adb shell pm disable-user --user 0 $package
  #       echo "Disabled $package"
  #     fi
  #   fi
  # done

  # for package in "${packages[@]}"; do
  #   if [[ ${package:0:1} == "#" ]]; then
  #     echo ""
  #     echo "$package"
  #   elif isPackageInstalled $package; then
  #     if [[ $skip == false ]]; then
  #       read -p "Disable $package? (y/n): " response
  #     elif [[ $skip == true ]]; then
  #       response="y"
  #     fi
  #     if [[ $response == "y" ]]; then
  #       adb shell pm disable-user --user 0 $package
  #       echo "Disabled $package"
  #     fi
  #   fi
  # done
}

apkUninstall () {
  local skip=false

  if [ "$1" = "skip" ]; then
    skip=true
  fi

  for package in "${packages[@]}"; do
    if [[ ${package:0:1} == "#" ]]; then
      echo ""
      echo "$package"
    elif isPackageInstalled $package; then
      if [[ $skip == false ]]; then
        read -p "Uninstall $package? (y/n): " response
      elif [[ $skip == true ]]; then
        response="y"
      fi
      if [[ $response == "y" ]]; then
        adb shell pm uninstall --user 0 $package
        echo "Unistalled $package"
      fi
    fi
  done
}

apkRemoval(){
  local skip=false
  local removal='d'

  echo ""
  echo "Begin removing APK files from your Android device."

  read -p "Do you want to confirm removal of each file (y), yes to all (a) or cancel (c)? (y/a/c): " confirm
  echo ""
  case $confirm in
    y)
      skip=false
      ;;
    a)
      skip=true
      ;;
    c)
      echo "Removal cancelled."
      ;;
    *)
      echo "Invalid input. Please enter y, a or c."
      ;;
  esac

  if [[ $skip == true ]]; then
    read -p "Disable all APKs or Uninstall? C for cancel (d/u/c): " confirm
    case $confirm in
      d)
        removal='d'
        ;;
      u)
        removal='u'
        ;;
      c)
        echo "Removal cancelled."
        ;;
      *)
        echo "Invalid input. Please enter d, u or c."
        ;;
  esac
  fi

  for package in "${packages[@]}"; do
    apk=$(echo "$package" | cut -f1)
    list=$(echo "$package" | cut -f2)
    description=$(echo "$package" | cut -f3)
    removal=$(echo "$package" | cut -f4)

    # Check if installed
    if isPackageInstalled $apk; then
      echo ""
      echo "List: $list"
      echo "Removal Type: $removal"
      echo "APK file: $apk"
      echo "Description: $description"
      echo ""

      # Check for 'skip'
      if [[ $skip == false ]]; then
        read -p "Disable or Uninstall: $apk? (d/u): " response

      elif [[ $skip == true ]]; then
        response=$removal
      fi

      # Disable APK
      if [[ $response == "d" ]]; then
        adb shell pm disable-user --user 0 $apk
        echo "Disabled: $apk"

      # Uninstall APK
      elif [[ $response == "u" ]]; then
        adb shell pm uninstall --user 0 $apk
        echo "Uninstalled: $apk"
      fi
    fi
  done
}

removePackages() {
  echo "" # Blank line
  echo "Begin removing APK files from your Android device."

  read -p "Do you want to confirm removal of each file (y), yes to all (a) or cancel (c)? (y/a/c): " confirm

  case $confirm in
    y)
      read -p "Do you want to disable (d) or uninstall (u) packages? (d/u): " action

      case $action in
        d)
          apkDisable          
          ;;
        u)
          apkUninstall
          ;;
        *)
          echo "Invalid input. Please enter d or u."
          ;;
      esac
      ;;
    a)
      read -p "Do you want to disable (d) or uninstall (u) packages? (d/u): " action

      case $action in
        d)
          apkDisable skip
          ;;
        u)
          apkUninstall skip
          ;;
        *)
          echo "Invalid input. Please enter d or u."
          ;;
      esac
      ;;
    c)
      echo "Removal cancelled."
      ;;
    *)
      echo "Invalid input. Please enter y, a or c."
      ;;
  esac
}

restorePackages() {
  echo "" # Blank line
  echo "Attempting to re-install cached APK files on your Android device."

  read -p "Do you want to confirm installation of each file (y), yes to all (a) or cancel (c)? (y/a/c): " confirm

  case $confirm in
    y)
      for package in "${packages[@]}"; do
        if [[ ${package:0:1} == "#" ]]; then
          echo "" # Blank line
          echo "$package"
        elif isPackageCached $package; then
          read -p "Install $package? (y/n): " response
          if [[ $response == "y" ]]; then
            adb shell pm install-existing --user 0 $package # attempt to reinstall
            adb shell pm enable --user 0 $package # attempt to enable
            if ! isPackageInstalled $package; then # verify $package was installed and enabled
              echo "Failed to install $package."
            else
              echo "Successfully installed $package."
            fi
          fi
        elif ! isPackageCached $package; then # package needs to be downloaded
          echo "Package not eligible for installation..."
          echo "Download $package from the Android Play Store"
        fi
      done
      ;;
    a)
      for package in "${packages[@]}"; do
        if [[ ${package:0:1} == "#" ]]; then
          echo "" # Blank line
          echo "$package"
        elif isPackageCached $package; then
          adb shell pm install-existing --user 0 $package # attempt to reinstall
          adb shell pm enable --user 0 $package # attempt to enable
          if ! isPackageInstalled $package; then # verify $package was installed and enabled
            echo "Failed to install $package."
          else
            echo "Successfully installed $package."
          fi
        elif ! isPackageCached $package; then # package needs to be downloaded
          echo "Package not eligible for installation..."
          echo "Download $package from the Android Play Store"
        fi
      done
      ;;
    c)
      echo "Removal cancelled."
      ;;
    *)
      echo "Invalid input. Please enter y, a, or c."
      ;;
  esac
}

listPackagesDisabled() {
  # run adb command to list all packages disabled or uninstalled from the device
  adb shell pm list packages -d
}

exportApkList() {
  local search_word="$1"
  local output_file="lists/export-lists/apk_export_list_${search_word}.txt"

  if [ -z "$search_word" ]; then
    read -p "Enter a keyword to search for (ex: tmobile, att, google, android, opus, oneplus, qualcomm, cn, remote): " search_word
    output_file="lists/export-lists/apk_export_list_${search_word}.txt"
  fi

  echo "Exporting APK list to $output_file..."

  > $output_file  # clear the file

  for package in $(adb shell pm list packages -f); do
    package_path=$(echo $package | cut -d ':' -f 2)
    # package_dir=${package_path%*.apk} # extracts the full directory path
    package_dir=${package_path%.apk=*}  # extracts the directory path
    package_name=${package_path##*.apk=} # extracts the package name
    package_version=$(adb shell dumpsys package $package_name | grep "versionName" | cut -d '=' -f 2)

    if adb shell pm list packages -d | grep -q $package_name; then
      package_status="disabled"
    elif adb shell pm list packages -e | grep -q $package_name; then
      package_status="enabled"
    else
      package_status="uninstalled"
    fi

    # export only matching packages
    if [[ $package_name =~ $search_word ]]; then
      echo "Package: $package_name" >> $output_file
      echo "  Version: $package_version" >> $output_file
      echo "  Status: $package_status" >> $output_file
      echo "  Directory: $package_dir" >> $output_file # add the package directory
      echo "" >> $output_file # add a blank line between packages
    fi
  done

  echo "Export complete!"
  echo ""
}

menuHome() {
  # Define the menu options
  local options=("Debloat" "------" "Restore" "------" "Export APKs (slow)" "------" "Reboot Phone" "------" "Exit Script")

  # Display the menu
  echo "Menu:"

  for ((i=0; i<${#options[@]}; i++)); do
    echo "  $((i+1)). ${options[$i]}"
  done
  echo "------"

  # Read user input
  read -p "Enter the number of your choice: " choice

  # Menu logic:
  if [[ $choice -gt 0 && $choice -le ${#options[@]} ]]; then
  # 1. Debloat
    if [[ $choice -eq 1 ]]; then
      submenuDebloat
  # ------
  # 3. Restore:
    elif [[ $choice -eq 3 ]]; then
      submenuRestore
  # ------
  # 5. Export List
    elif [[ $choice -eq 5 ]]; then
      exportApkList
  # ------
  # 7. Reboot Phone
    elif [[ $choice -eq 7 ]]; then
      rebootAndroid  
  # ------
  # 9. Menu Exit
    elif [[ $choice -eq 9 ]]; then
      menuExit
    fi
  else
    echo "Invalid menu choice. Please try again."
  fi
}

submenuDebloat() {
  local choice

  while true; do
    # Define the submenu options
    local options=("ASOP" "Carrier" "Google" "Manufacturer" "JSON" "Custom" "Back to Main Menu")

    # Display the submenu
    echo "Debloat Submenu:"
    for ((i=0; i<${#options[@]}; i++)); do
      echo "  $((i+1)). ${options[$i]}"
    done
    echo "------"

    # Read user input
    read -p "Enter the number of your choice: " choice

    # Submenu logic:
    if [[ $choice -gt 0 && $choice -le ${#options[@]} ]]; then
      # Handle submenu options
      case $choice in
        1) loadPackages "lists/${options[$choice-1],,}.txt"; removePackages ;;
        2) loadPackages "lists/${options[$choice-1],,}.txt"; removePackages ;;
        3) loadPackages "lists/${options[$choice-1],,}.txt"; removePackages ;;
        4) loadPackages "lists/${options[$choice-1],,}.txt"; removePackages ;;
        5) loadPackages "lists/${options[$choice-1],,}.txt"; removePackages ;;
        6) loadPackages "lists/${options[$choice-1],,}.txt"; removePackages ;;
        7) return ;; # Go back to main menu
      esac
    else
      echo "Invalid submenu choice. Please try again."
    fi
  done
}

submenuRestore() {
  local choice

  while true; do
    # Define the submenu options
    local options=("ASOP" "Carrier" "Google" "Manufacturer" "JSON" "Custom" "Back to Main Menu")

    # Display the submenu
    echo "Restore Submenu:"
    for ((i=0; i<${#options[@]}; i++)); do
      echo "  $((i+1)). ${options[$i]}"
    done
    echo "------"

    # Read user input
    read -p "Enter the number of your choice: " choice

    # Submenu logic:
    if [[ $choice -gt 0 && $choice -le ${#options[@]} ]]; then
      # Handle submenu options
      case $choice in
        1) loadPackages "lists/${options[$choice-1],,}.txt"; restorePackages ;;
        2) loadPackages "lists/${options[$choice-1],,}.txt"; restorePackages ;;
        3) loadPackages "lists/${options[$choice-1],,}.txt"; restorePackages ;;
        4) loadPackages "lists/${options[$choice-1],,}.txt"; restorePackages ;;
        5) loadPackages "lists/${options[$choice-1],,}.txt"; restorePackages ;;
        6) loadPackages "lists/${options[$choice-1],,}.txt"; restorePackages ;;
        7) return ;; # Go back to main menu
      esac
    else
      echo "Invalid submenu choice. Please try again."
    fi
  done
}

# Check for a connected Android device
if ! checkDevice; then
  echo "" # Blank line
  echo "No Android device found. Please connect a device and try again."
  exit 1
fi

# loadJSON lists/master-lists/UAD-lists/uad_lists.json list Oem removal Recommended
# apkRemoval

# Call the menuHome function to start the menu
while true; do
    menuHome
done