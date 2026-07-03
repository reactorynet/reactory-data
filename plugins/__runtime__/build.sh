#!/usr/bin/env bash
#
# build.sh - Build a runtime plugin with rollup.
#
# Wraps the incantation required to invoke rollup under Yarn Berry (PnP)
# while passing a config filename that contains '@' (which Yarn's `run`
# shim would otherwise interpret as a scope/version separator).
#
# Usage:
#   ./build.sh <rollup-config-file>
#
# Example:
#   ./build.sh rollup.core.ApplicationCard@1.0.0.js
#
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <rollup-config-file>" >&2
  exit 1
fi

CONFIG_FILE="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ ! -f "${SCRIPT_DIR}/${CONFIG_FILE}" && ! -f "${CONFIG_FILE}" ]]; then
  echo "Error: rollup config file not found: ${CONFIG_FILE}" >&2
  exit 1
fi

cd "${SCRIPT_DIR}"

ROLLUP_BIN="$(yarn bin rollup)"
exec yarn node "${ROLLUP_BIN}" --config "${CONFIG_FILE}"
