#!/bin/bash

# Toy Robot Simulation CLI
# Main entry point for the robot simulation application

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source the robot simulation modules
source "${SCRIPT_DIR}/src/robot.sh"
source "${SCRIPT_DIR}/src/command-parser.sh"

# State variables
declare -g ROBOT_X=
declare -g ROBOT_Y=
declare -g ROBOT_DIRECTION=
declare -g ROBOT_PLACED=false

# Initialize the robot simulator
main() {
  local input_file="${1:-}"

  if [[ -z "$input_file" ]]; then
    # Read from stdin
    while IFS= read -r line; do
      process_command "$line"
    done
  else
    # Read from file
    if [[ ! -f "$input_file" ]]; then
      echo "Error: File '$input_file' not found" >&2
      exit 1
    fi

    while IFS= read -r line; do
      process_command "$line"
    done < "$input_file"
  fi
}

# Process a single command
process_command() {
  local command="$1"

  # Skip empty lines and comments
  [[ -z "$command" || "$command" =~ ^[[:space:]]*# ]] && return 0

  # Trim whitespace
  command=$(echo "$command" | xargs)

  # Parse and execute command
  parse_command "$command"
}

main "$@"
