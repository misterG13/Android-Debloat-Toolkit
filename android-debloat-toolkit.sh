#!/bin/bash

menuExit() {
  echo "Goodbye!"
  sleep 1
  exit 0
}

rebootAndroid() {
  adb reboot
  menuExit
}

checkDevice() {
  # adb devices | grep -q "device"
  # return $?

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
  declare -g packages  # declare packages as a global variable
  # mapfile -t packages < <(grep -v '^[[:space:]]*$\|#' "$filename") # skip lines that are blank or begin with "#"
  mapfile -t packages < <(grep -v '^[[:space:]]*$' "$filename") # skip lines that are blank
  # for package in "${packages[@]}"; do
  #   echo "Package: $package"
  # done
}

isPackageInstalled() {
  local package=$1

  # check if a package is installed and disabled
  if adb shell pm list packages -d | grep -q $package; then
    echo "$package is disabled."
    # false
    return 1
  # check if a package is installed and enabled
  elif adb shell pm list packages -e | grep -q $package; then
    # true
    return 0
  # must be uninstalled
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

  if [ "$1" = "skip" ]; then
    skip=true
  fi

  for package in "${packages[@]}"; do
    if [[ ${package:0:1} == "#" ]]; then
      echo ""
      echo "$package"
    elif isPackageInstalled $package; then
      if [[ $skip == false ]]; then
        read -p "Disable $package? (y/n): " response
      elif [[ $skip == true ]]; then
        response="y"
      fi
      if [[ $response == "y" ]]; then
        adb shell pm disable-user --user 0 $package
        echo "Disabled $package"
      fi
    fi
  done
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
    read -p "Enter a keyword to search for: " search_word
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
}

menuHome() {
  # Define the menu options
  local options=("Debloat:" "Google" "OnePlus" "TMobile" "Custom" "------" "Restore:" "Google" "OnePlus" "Tmobile" "Custom" "------" "Export List (slow)" "Google" "OnePlus" "TMobile" "Custom" "------" "Reboot Phone" "Exit Script")

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
  # 1. Debloat:
    # 2. Google
    if [[ $choice -eq 2 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      removePackages
    # 3. OnePlus
    elif [[ $choice -eq 3 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      removePackages
    # 4. TMobile
    elif [[ $choice -eq 4 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      removePackages
    # 5. Custom
    elif [[ $choice -eq 5 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      removePackages

  # 7. Restore:
    # 8. Google
    elif [[ $choice -eq 8 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      restorePackages
    # 9. OnePlus
    elif [[ $choice -eq 9 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      restorePackages
    # 10. TMobile
    elif [[ $choice -eq 10 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      restorePackages
    # 11. Custom
    elif [[ $choice -eq 11 ]]; then
      loadPackages "lists/${options[$choice-1],,}.txt"
      restorePackages

  # 13. Export List:
    # 14. Google
    elif [[ $choice -eq 14 ]]; then
      exportApkList "${options[$choice-1],,}"
    # 15. OnePlus
    elif [[ $choice -eq 15 ]]; then
      exportApkList "${options[$choice-1],,}"
    # 16. TMobile
    elif [[ $choice -eq 16 ]]; then
      exportApkList "${options[$choice-1],,}"
    # 17. Custom
    elif [[ $choice -eq 17 ]]; then
      exportApkList
  # Reboot Phone
    elif [[ $choice -eq 19 ]]; then
      rebootAndroid  
  # Menu Exit
    elif [[ $choice -eq 20 ]]; then
      menuExit
  fi
  else
    echo "Invalid menu choice. Please try again."
  fi
}

# Check for a connected Android device
if ! checkDevice; then
  echo "" # Blank line
  echo "No Android device found. Please connect a device and try again."
  exit 1
fi

# Call the menuHome function to start the menu
while true; do
    menuHome
done
