# shellcheck shell=bash
# shellcheck disable=SC2034

declare -g PROJECT_DIR=${PROJECT_DIR:-$PWD}
declare -g LIST_FILE=${LIST_FILE:-}
declare -g SNAPSHOT_FILE=${SNAPSHOT_FILE:-}

# Load entries of an export-format JSON list into the $packages global
# as tab-separated rows: id, list, description, removal.
# When $status_filter is given, only entries with that "status" are loaded.
loadJSON() {
  local file=$1
  local status_filter=${2:-}
  local filter=""

  if [ ! -f "$file" ]; then
    echo "Error: File not found: $file"
    return 1
  fi

  if ! command -v jq >/dev/null 2>&1; then
    echo "Error: jq is required for JSON lists but was not found in PATH."
    return 1
  fi

  declare -g packages

  if [[ -n $status_filter ]]; then
    filter="select(.status == \"$status_filter\") | "
  fi

  mapfile -t packages < <(jq -r ".[] | $filter [.id, (.list // \"\"), (.description // \"\"), (.removal // \"\")] | @tsv" "$file")
  LIST_FILE=$file
}

# Let the user pick a JSON list from $dir. Returns 0 and loads it via
# loadJSON, or 1 if no list is available.
selectJSONList() {
  local dir=$1
  local status_filter=${2:-}
  local -a json_files
  local count
  local choice=""
  local i

  json_files=("$dir"/*.json)

  if [[ ! -e ${json_files[0]} ]]; then
    echo "No JSON lists found in $dir."
    echo "Use 'Export APK List' to create one, or place a JSON file there."
    return 1
  fi

  count=${#json_files[@]}

  if (( count == 1 )); then
    loadJSON "${json_files[0]}" "$status_filter" || return 1
    return 0
  fi

  echo ""
  echo "Available JSON lists:"
  for ((i = 0; i < count; i++)); do
    echo "$((i + 1)). $(basename "${json_files[$i]}")"
  done
  read -rp "Select a list (1-$count): " choice

  if [[ $choice =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= count )); then
    loadJSON "${json_files[$((choice - 1))]}" "$status_filter" || return 1
    return 0
  fi

  echo "Invalid selection."
  return 1
}