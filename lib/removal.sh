# shellcheck shell=bash

declare -g packages
declare -g PROJECT_DIR=${PROJECT_DIR:-$PWD}

apkRemoval(){
  local skip=false
  local removalType='d'
  local confirm=""
  local response=""
  local -a snapshot_actions=()
  local json_map
  local tmpfile
  local output=""
  local -i rc=0

  clear
  echo "Begin removing APK files from your Android device."
  echo ""

  read -rp "For each APK, do you want to (C)onfirm removal of each, yes to (A)ll or (E)xit? (C/A/E): " confirm
  echo ""

  case ${confirm,,} in
    c) skip=false ;;
    a) skip=true ;;
    e) echo "Removal cancelled."; mainMenu; return ;;
    *) echo "Invalid input. Please enter (C)onfirm, (A)ll or (E)xit."; mainMenu; return ;;
  esac

  if [[ $skip == true ]]; then
    read -rp "For all APKs in this list: (D)isable, (U)ninstall or (C)ancel? (D/U/C): " confirm
    echo ""

    case ${confirm,,} in
      d) removalType='d' ;;
      u) removalType='u' ;;
      c) echo "Removal cancelled."; mainMenu; return ;;
      *) echo "Invalid input. Please enter (D)isable, (U)ninstall or (C)ancel."; mainMenu; return ;;
    esac
  fi

  refreshPackageState || { echo "Debloat aborted."; mainMenu; return; }

  # Loop through the $packages global, set by loadJSON()
  for package in "${packages[@]}"; do
    apk=$(cut -f1 <<<"$package")
    list=$(cut -f2 <<<"$package")
    description=$(cut -f3 <<<"$package")
    removal=$(cut -f4 <<<"$package")

    # Skip malformed entries (also blocks injection into adb shell)
    if ! is_valid_package "$apk"; then
      echo "Skipping invalid package entry: $apk"
      continue
    fi

    # Check if installed
    if isPackageInstalled "$apk"; then
      echo ""
      [[ -n $list ]] && echo "List: $list"
      [[ -n $removal ]] && echo "Removal Type: $removal"
      echo "APK file: $apk"
      [[ -n $description ]] && echo "Description: $description"
      echo ""

      # Check for 'skip'
      if [[ $skip == false ]]; then
        read -rp "(D)isable, (U)ninstall, (S)kip or (E)xit: $apk? (D/U/S/E): " response
        echo ""

      elif [[ $skip == true ]]; then
        response=$removalType
      fi

      # Make response all lowercase
      response=${response,,}

      # Handle response
      case $response in
        # Disable
        d)
          output=$(adb_cmd shell pm disable-user --user 0 "$apk" 2>&1)
          rc=$?
          if (( rc == 0 )); then
            echo "Disabled: $apk"
            writeLog "$list" "$apk" "disable" "ok"
            snapshot_actions+=("$apk|disable")
          elif grep -qi "protected package" <<<"$output"; then
            echo "Skipping protected package (cannot disable): $apk"
            writeLog "$list" "$apk" "disable" "failed"
          else
            [[ -n $output ]] && echo "$output"
            echo "Failed to disable: $apk"
            writeLog "$list" "$apk" "disable" "failed"
          fi
          sleep 1 ;;
        # Uninstall
        u)
          output=$(adb_cmd shell pm uninstall --user 0 "$apk" 2>&1)
          rc=$?
          if (( rc == 0 )); then
            echo "Uninstalled: $apk"
            writeLog "$list" "$apk" "uninstall" "ok"
            snapshot_actions+=("$apk|uninstall")
          elif grep -qi "protected package" <<<"$output"; then
            echo "Skipping protected package (cannot uninstall): $apk"
            writeLog "$list" "$apk" "uninstall" "failed"
          else
            [[ -n $output ]] && echo "$output"
            echo "Failed to uninstall: $apk"
            writeLog "$list" "$apk" "uninstall" "failed"
          fi
          sleep 1 ;;
        # Skip
        s) echo "Skipping: $apk"; sleep 1 ;;
        # Exit
        e) echo "Removal cancelled."; mainMenu; return ;;
        # Invalid response
        *) echo "Invalid response. Please try again." ;;
      esac

    # Not Installed
    else
      echo "$apk not installed, skipping."
    fi
  done

  # Record performed actions in the device's debloat snapshot
  if (( ${#snapshot_actions[@]} > 0 )) && [[ -n ${SNAPSHOT_FILE:-} ]]; then
    json_map="{"
    for entry in "${snapshot_actions[@]}"; do
      apk=${entry%|*}
      action=${entry##*|}
      json_map+="\"$(json_escape "$apk")\":\"$action\","
    done
    json_map=${json_map%,}
    json_map+="}"

    tmpfile="$SNAPSHOT_FILE.tmp"
    if jq --argjson m "$json_map" \
      'map((.id as $id | $m[$id]) as $a | if $a then .status = "disabled" | .removal = $a else . end)' \
      "$SNAPSHOT_FILE" > "$tmpfile" 2>/dev/null; then
      mv "$tmpfile" "$SNAPSHOT_FILE"
    else
      rm -f "$tmpfile"
      echo "Warning: could not update debloat snapshot: $SNAPSHOT_FILE"
    fi
  fi

  echo ""
  read -rp "Removal complete, return to (M)ain Menu or (E)xit? (M/E): " response
  echo ""

  # Make response all lowercase
  response=${response,,}

  # Handle response
  case $response in
    m) mainMenu ;;
    e) exitScript ;;
    *) mainMenu ;;
  esac
}

# Debloat a JSON list
debloatList() {
  local snap_dir=""
  local file_name=""
  local list_dir=""
  local response=""

  clear
  echo "Debloat reads a JSON list from either source directory:"
  echo ""
  echo "  (E)xported lists   $PROJECT_DIR/lists/exported"
  echo "  (C)ustomized lists $PROJECT_DIR/lists/customized"
  echo ""
  read -rp "Choose a source (E/C): " response

  case ${response,,} in
    c) list_dir="$PROJECT_DIR/lists/customized" ;;
    *) list_dir="$PROJECT_DIR/lists/exported" ;;
  esac

  selectJSONList "$list_dir" || { mainMenu; return; }

  # Copy the chosen list into a per-device snapshot that doubles as the
  # restore list for this device (overwrites any previous snapshot).
  snap_dir="$PROJECT_DIR/lists/debloated/$(getSerial)"
  file_name=$(basename "$LIST_FILE")
  mkdir -p "$snap_dir" || { echo "Error: could not create $snap_dir"; mainMenu; return; }
  SNAPSHOT_FILE="$snap_dir/$file_name"
  if ! cp "$LIST_FILE" "$SNAPSHOT_FILE"; then
    echo "Error: could not copy list '$LIST_FILE' to '$SNAPSHOT_FILE'."
    SNAPSHOT_FILE=""
    mainMenu
    return
  fi

  apkRemoval
}