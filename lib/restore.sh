# shellcheck shell=bash

declare -g packages
declare -g PROJECT_DIR=${PROJECT_DIR:-$PWD}

apkRestore() {
  local skip=false
  local confirm=""
  local response=""
  local -a restored_pkgs=()
  local ids_json
  local tmpfile

  clear
  echo "Begin restoring APK files from your Android device."
  echo ""

  read -rp "For each APK, do you want to (C)onfirm restoration of each, yes to (A)ll or (E)xit? (C/A/E): " confirm
  echo ""

  # Set $skip variable
  case ${confirm,,} in
    c) skip=false ;;
    a) skip=true ;;
    e) echo "Restore cancelled."; mainMenu; return ;;
    *) echo "Invalid input. Please enter (C)onfirm, (A)ll or (E)xit."; mainMenu; return ;;
  esac

  refreshPackageState || { echo "Restore aborted."; mainMenu; return; }

  # Loop through the $packages global, set by loadJSON()
  for package in "${packages[@]}"; do
    apk=$(cut -f1 <<<"$package")
    list=$(cut -f2 <<<"$package")
    description=$(cut -f3 <<<"$package")
    removal=$(cut -f4 <<<"$package")

    # Skip malformed entries
    if ! is_valid_package "$apk"; then
      echo "Skipping invalid package entry: $apk"
      continue
    fi

    # Check Android cache for $apk
    if isPackageCached "$apk"; then
      echo ""
      [[ -n $list ]] && echo "List: $list"
      [[ -n $removal ]] && echo "Removal Type: $removal"
      echo "APK file: $apk"
      [[ -n $description ]] && echo "Description: $description"
      echo ""

      # Check for 'skip'
      if [[ $skip == false ]]; then
        read -rp "(R)estore, (S)kip or (E)xit: $apk? (R/S/E): " response
        echo ""

      elif [[ $skip == true ]]; then
        response="r"
      fi

      # Make response all lowercase
      response=${response,,}

      # Handle response
      case $response in
        # Restore
        r)
          if adb_cmd shell pm install-existing --user 0 "$apk"; then
            adb_cmd shell pm enable --user 0 "$apk" >/dev/null 2>&1
            refreshPackageState
            if isPackageInstalled "$apk"; then
              echo "Successfully restored $apk."
              writeLog "$list" "$apk" "restore" "ok"
              restored_pkgs+=("$apk")
            else
              echo "Failed to restore $apk."
              writeLog "$list" "$apk" "restore" "failed"
            fi
          else
            echo "Failed to restore $apk."
            writeLog "$list" "$apk" "restore" "failed"
          fi
          echo ""
          ;;
        # Skip
        s) echo "Skipping: $apk"; sleep 1 ;;
        # Exit
        e) echo "Restore cancelled."; mainMenu; return ;;
        # Invalid input
        *) echo "Invalid input. Please enter (R)estore, (S)kip or (E)xit."; mainMenu; return ;;
      esac

    # Not Installed
    else
      echo "$apk not disabled, skipping."
    fi
  done

  # Mark restored entries back to enabled in the device's debloat snapshot
  if (( ${#restored_pkgs[@]} > 0 )) && [[ -n ${SNAPSHOT_FILE:-} ]]; then
    ids_json="["
    for apk in "${restored_pkgs[@]}"; do
      ids_json+="\"$(json_escape "$apk")\","
    done
    ids_json=${ids_json%,}
    ids_json+="]"

    tmpfile="$SNAPSHOT_FILE.tmp"
    if jq --argjson ids "$ids_json" \
      'map(if (.id as $id | $ids | index($id)) then .status = "enabled" | .removal = "" else . end)' \
      "$SNAPSHOT_FILE" > "$tmpfile" 2>/dev/null; then
      mv "$tmpfile" "$SNAPSHOT_FILE"
    else
      rm -f "$tmpfile"
      echo "Warning: could not update debloat snapshot: $SNAPSHOT_FILE"
    fi
  fi

  echo ""
  read -rp "Restoration complete, return to (M)ain Menu or (E)xit? (M/E): " response
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

# Restore a JSON list
restoreList() {
  clear
  selectJSONList "$PROJECT_DIR/lists/debloated/$(getSerial)" disabled || { mainMenu; return; }
  SNAPSHOT_FILE=$LIST_FILE
  apkRestore
}