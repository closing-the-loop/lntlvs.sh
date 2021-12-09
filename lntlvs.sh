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

set -e

### Check if dependencies are installed.
################################################################################
if ! command -v jq &> /dev/null; then
    echo "This script needs 'jq' to run. Consider installing it."
    exit 1
fi

if ! command -v xxd &> /dev/null; then
    echo "This script needs 'xxd' to run. Consider installing it."
    exit 1
fi

### Configure script defaults.
################################################################################

NETWORK="mainnet"
INDEXOFFSET=0
MAX_INVOICES=1000
TLV_KEY=7629169 # See https://github.com/satoshisstream/satoshis.stream/blob/main/TLV_registry.md.
LNCLI_WRAPPER="./bitcoin-lncli.sh" # The lncli wrapper script on a BTCPay Server.

unset OUTPUT

### Parse command line arguments.
################################################################################
usage () {
  echo -e "Usage:"
  echo -e "\t$0 [OPTIONS]\n"
  echo -e "Options:"
  echo -e "\t--network <value>\tThe network lnd is running on. (default: mainnet)"
  echo -e "\t--indexoffset <value>\tQuery only for invoices after this offset. (default: 0)"
  echo -e "\t--maxinvoices <value>\tThe max number of invoices to query. (default: 1000)"
  echo -e "\t--tlvkey <value>\tThe TLV key to extract and decode. (default: 7629169)"
  echo -e "\t--lncliwrapper <value>\tA wrapper script to use instead if lncli is not available. (default: ./bitcoin-lncli.sh)"
  echo -e "\t--output <value>\tIf set, custom records will be written to this file in JSON Lines format (one JSON per line)."
}

while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    --network)        NETWORK="$2"       ; shift 2 ;;
    --indexoffset)    INDEXOFFSET="$2"   ; shift 2 ;;
    --maxinvoices)    MAX_INVOICES="$2"  ; shift 2 ;;
    --tlvkey)         TLV_KEY="$2"       ; shift 2 ;;
    --lncliwrapper)   LNCLI_WRAPPER="$2" ; shift 2 ;;
    --output)         OUTPUT="$2"        ; shift 2 ;;
    --help) usage; exit;;
    *) echo "Unknown option: $1."; usage; exit 2;;
  esac
done

### Get Invoices from lncli or wrapper script.
################################################################################

if ! command -v lncli &> /dev/null && ! [ -f $LNCLI_WRAPPER ]; then
    echo "Error: Neither lncli nor $LNCLI_WRAPPER found."
    exit 1
fi

lncli_command() {
  if ! command -v lncli &> /dev/null; then
    LNCLI_WRAPPER_DIR="$(cd -- "$(dirname "$LNCLI_WRAPPER")" && pwd)"
    LNCLI_WRAPPER_FILE="$(basename "$LNCLI_WRAPPER")"
    LNCLI_WRAPPER_FULL_PATH="$LNCLI_WRAPPER_DIR/$LNCLI_WRAPPER_FILE"
    echo $LNCLI_WRAPPER_FULL_PATH
  else
    echo "lncli"
  fi
}

invoices=$(
  $(lncli_command) \
    --network $NETWORK \
    listinvoices \
    --max_invoices=$MAX_INVOICES \
    --index_offset=$INDEXOFFSET \
    --paginate-forwards
)

### Parse and decode custom records that have the specified TLV key.
################################################################################

custom_records=$(
  echo $invoices \
    | jq -r --arg tlv_key "$TLV_KEY" '
      .invoices[]
        | select(.is_keysend)
        | select(.state == "SETTLED")
        | .htlcs[]
        | .custom_records
        | .[$tlv_key]' \
    | xxd -r -p
)

### Output results.
################################################################################

if [ -z "$OUTPUT" ]; then
  echo $custom_records | jq -s '.'
else
  OUTPUT_DIR="$(cd -- "$(dirname "$OUTPUT")" && pwd)"
  OUTPUT_FILE="$(basename "$OUTPUT")"
  OUTPUT_FULL_PATH="$OUTPUT_DIR/$OUTPUT_FILE"

  mkdir -p $OUTPUT_DIR
  echo $custom_records | jq -c '.' > $OUTPUT_FULL_PATH
fi
