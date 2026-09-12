# shellcheck shell=bash

declare -g enabled_pkgs=()
declare -g disabled_pkgs=()

refreshPackageState() {
  # Cache enabled and disabled package lists once instead of querying
  # adb separately for every package name.
  local line

  enabled_pkgs=()
  disabled_pkgs=()

  while IFS= read -r line; do
    enabled_pkgs+=("${line#package:}")
  done < <(adb_cmd shell pm list packages -e 2>/dev/null | tr -d '\r')

  while IFS= read -r line; do
    disabled_pkgs+=("${line#package:}")
  done < <(adb_cmd shell pm list packages -d 2>/dev/null | tr -d '\r')

  # An unplugged device or dead adb server returns nothing; treat it as a hard error.
  if (( ${#enabled_pkgs[@]} == 0 )); then
    echo "Error: adb returned no installed packages. Check the device connection."
    return 1
  fi
  return 0
}

# Only allow characters that are valid in Android package names
is_valid_package() {
  [[ $1 =~ ^[a-zA-Z][a-zA-Z0-9._]*$ ]]
}

# Escape a string for use inside a double-quoted JSON string
json_escape() {
  local string="$1"

  string=${string//\\/\\\\}
  string=${string//\"/\\\"}
  string=${string//$'\n'/\\n}
  string=${string//$'\r'/\\r}
  string=${string//$'\t'/\\t}
  printf '%s' "$string"
}

isPackageInstalled() {
  local package=$1

  # Installed & Enabled
  [[ " ${enabled_pkgs[*]} " == *" $package "* ]]
}

isPackageCached() {
  local package="$1"

  # Installed & Disabled
  [[ " ${disabled_pkgs[*]} " == *" $package "* ]]
}