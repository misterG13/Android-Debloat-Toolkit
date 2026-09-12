# shellcheck shell=bash

declare -g PROJECT_DIR=${PROJECT_DIR:-$PWD}

apkExport() {
  local search_word="${1:-}"
  local file_loc="$PROJECT_DIR/lists/exported/"
  local file_name="apk_list_"
  local output_file
  local model_name
  local pkgs
  local package_count
  local package
  local package_path
  local package_dir
  local package_name
  local package_version
  local package_status
  local package_description
  local response=""
  local output="["
  local first_entry=true
  local -i i

  clear

  # Check for search_word passed as a function argument
  if [ -z "$search_word" ]; then
    # Ask user for a search term
    read -rp "Enter ONE or NO keyword (ex: cn, google, lock, oneplus, oplus, qualcomm, remote, tmo, tmobile): " search_word

    # Make response all lowercase
    search_word=${search_word,,}
    # Remove anything unsuitable for a filename
    search_word=${search_word//[^a-zA-Z0-9._-]/_}
  fi

  # ADB shell to get phone's model name
  model_name=$(adb_cmd shell getprop ro.product.model 2>/dev/null | tr -d '\r')
  # Remove anything unsuitable for a filename
  model_name=${model_name//[^a-zA-Z0-9._-]/_}
  if [[ -z $model_name ]]; then
    model_name="device"
  fi

  # Build output_file
  if [[ ! $search_word ]]; then
    output_file="${file_loc}${file_name}${model_name}.json"
  else
    output_file="${file_loc}${file_name}${model_name}_${search_word}.json"
  fi

  mkdir -p "$file_loc"

  echo "Exporting $model_name's APK list to: $output_file"

  refreshPackageState || { echo "Export aborted."; mainMenu; return; }

  pkgs=()
  while IFS= read -r package; do
    pkgs+=("$package")
  done < <(adb_cmd shell pm list packages -f 2>/dev/null | tr -d '\r')
  package_count=${#pkgs[@]}

  for ((i = 0; i < package_count; i++)); do
    package=${pkgs[$i]}
    package_path=$(cut -d ':' -f 2 <<<"$package")
    package_dir=${package_path%.apk=*}  # extracts the directory path
    package_name=${package_path##*.apk=} # extracts the package name

    # Skip malformed package names
    if ! is_valid_package "$package_name"; then
      continue
    fi

    # Export only matching packages (literal, case-insensitive substring)
    if [[ "${package_name,,}" == *"${search_word,,}"* ]]; then
      package_version=$(adb_cmd shell dumpsys package "$package_name" 2>/dev/null | grep "versionName" | head -n 1 | cut -d '=' -f 2 | tr -d '\r')

      # Set package status from the cached list
      if isPackageCached "$package_name"; then
        package_status="disabled"
      else
        package_status="enabled"
      fi

      # Create description
      package_description="Version: ${package_version:-unknown}, Directory: $package_dir"

      if [[ $first_entry == true ]]; then
        first_entry=false
      else
        output+=","
      fi
      output+=$'\n  {\n    "id": "'
      output+="$(json_escape "$package_name")"
      output+=$'",\n    "list": "unknown",\n    "description": "'
      output+="$(json_escape "$package_description")"
      output+=$'",\n    "status": "'
      output+="$(json_escape "$package_status")"
      output+=$'",\n    "removal": "unknown"\n  }'
    fi
  done

  # Write valid JSON in one shot
  if [[ $first_entry == true ]]; then
    printf '[]\n' > "$output_file"
  else
    printf '%s\n' "${output}]" > "$output_file"
  fi

  echo ""
  read -rp "Export complete, return to (M)ain Menu or (E)xit? (M/E): " response
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