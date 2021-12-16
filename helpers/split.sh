#!/bin/bash

# lntlvs: TLV Payment Metadata Records Parser for LND
# Copyright (C) 2021  seetee.io

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

### Check if dependencies are installed.
################################################################################

if ! command -v split &> /dev/null; then
    echo "This script needs 'split' to run. Consider installing it."
    exit 1
elif [[ $(uname -s) == "Darwin" ]]; then
    if ! command -v gsplit &> /dev/null; then
        echo "This script needs 'gsplit' to run on macOS. Consider installing it."
        exit 1
    fi
fi

### Configure script defaults.
################################################################################

FILTER="\"message\":\".+\""

unset INPUT
unset OUTPUT

### Parse command line arguments.
################################################################################
usage () {
  echo -e "Usage:"
  echo -e "\t$0 [OPTIONS] INPUT_FILE OUTPUT_DIR\n"
  echo -e "\tWrites each line in INPUT_FILE to a file in OUTPUT_DIR."
  echo -e "\tThe filenames will be 'custom_record_NNNNN.json' where 'NNNNN' is an incrementing number starting with '00000'."
  echo -e "\tIf INPUT_FILE is set to '-', the script will read from stdin.\n"
  echo -e "Options:"
  echo -e "\t--filter <value>\tOutputs only those lines matching the given filter (case-insensitive). (default: \"message\":\".+\""
}

POSITIONAL=()

while [[ $# -gt 0 ]]; do
  arg="$1"
  case $arg in
    --filter) FILTER="$2"; shift 2 ;;
    --help) usage; exit;;
    *) POSITIONAL+=("$1"); shift ;;
  esac
done

set -- "${POSITIONAL[@]}"

if [[ $# -lt 2 ]]; then
    echo -e "Error: Requires two positional arguments: INPUT_FILE and OUTPUT_DIR.\n"
    usage
    exit 1
fi

split_command() {
  if [[ $(uname -s) == "Darwin" ]]; then
    # macOS `split`
    echo "gsplit"
  else
    # GNU `split`
    echo "split"
  fi
}

input_full_path=$1
if [ -f "$1" ]; then
    input_dir="$(cd -- "$(dirname "$1")" && pwd)"
    input_file="$(basename "$1")"
    input_full_path="$input_dir/$input_file"
fi

output_dir="$(cd -- "$(dirname "$2")" && pwd)"
output_file="$(basename "$2")"
output_full_path="$output_dir/$output_file"

if [ ! -d "$output_full_path" ]; then
    mkdir -p "$output_full_path"
fi

grep -i -E $FILTER "$input_full_path" \
    | $(split_command) \
        --numeric-suffixes \
        --lines 1 \
        - \
        "$output_full_path/custom_record_" \
        --additional-suffix ".json" \
        --suffix-length 5
