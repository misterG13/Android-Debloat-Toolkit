# shellcheck shell=bash

declare -g PROJECT_DIR=${PROJECT_DIR:-$PWD}
declare -g LOG_FILE=${LOG_FILE:-}
declare -g LOG_SERIAL=${LOG_SERIAL:-}
declare -g LOG_MODEL=${LOG_MODEL:-}

# Create today's audit log and capture device identity.
initLog() {
  local dir
  dir="$PROJECT_DIR/logs"

  if ! mkdir -p "$dir"; then
    echo "Error: could not create log directory: $dir"
    LOG_FILE=""
    return 1
  fi

  LOG_FILE="$dir/debloat-$(date +%Y%m%d-%H%M%S).log"
  LOG_SERIAL=$(getSerial)
  LOG_MODEL=$(adb_cmd shell getprop ro.product.model 2>/dev/null | tr -d '\r')
  printf 'timestamp,list,package,action,result,serial,model\n' > "$LOG_FILE"
}

# Append one debloat action to the audit log (creates it on first use).
writeLog() {
  local list=$1
  local package=$2
  local action=$3
  local result=$4
  local ts

  if [[ -z ${LOG_FILE:-} ]]; then
    initLog
  fi
  [[ -n ${LOG_FILE:-} ]] || return 0

  ts=$(date +%Y-%m-%dT%H:%M:%S%z)
  printf '%s,"%s",%s,%s,%s,%s,"%s"\n' "$ts" "$list" "$package" "$action" "$result" "${LOG_SERIAL:-unknown}" "${LOG_MODEL:-unknown}" >> "$LOG_FILE"
}