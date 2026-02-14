#!/bin/bash

# Command Parser
# Parses and executes robot commands

# Parse and execute a command
# Args: command string
parse_command() {
  local command="$1"

  # Extract command name (first word)
  local cmd_name="${command%% *}"
  cmd_name=$(echo "$cmd_name" | tr '[:lower:]' '[:upper:]')

  case "$cmd_name" in
    PLACE)
      handle_place "$command"
      ;;
    MOVE)
      handle_move "$command"
      ;;
    LEFT)
      handle_left "$command"
      ;;
    RIGHT)
      handle_right "$command"
      ;;
    REPORT)
      handle_report "$command"
      ;;
    *)
      # Invalid command - ignore silently as per requirements
      return 1
      ;;
  esac
}

# Handle PLACE command
# Format: PLACE X,Y,DIRECTION
handle_place() {
  local command="$1"
  # Extract everything after the first word (case-insensitive)
  local args="${command#* }"
  [[ "$args" == "$command" ]] && args=""
  args=$(echo "$args" | xargs)

  # Parse X,Y,DIRECTION
  if ! [[ "$args" =~ ^([0-9]+),([0-9]+),(NORTH|SOUTH|EAST|WEST)$ ]]; then
    return 1
  fi

  local x="${BASH_REMATCH[1]}"
  local y="${BASH_REMATCH[2]}"
  local direction="${BASH_REMATCH[3]}"

  place_robot "$x" "$y" "$direction"
}

# Handle MOVE command
handle_move() {
  local command="$1"
  local cmd_upper=$(echo "$command" | tr '[:lower:]' '[:upper:]')

  # Verify command format (case-insensitive)
  if ! [[ "$cmd_upper" =~ ^MOVE[[:space:]]*$ ]]; then
    return 1
  fi

  move_robot
}

# Handle LEFT command
handle_left() {
  local command="$1"
  local cmd_upper=$(echo "$command" | tr '[:lower:]' '[:upper:]')

  # Verify command format (case-insensitive)
  if ! [[ "$cmd_upper" =~ ^LEFT[[:space:]]*$ ]]; then
    return 1
  fi

  rotate_left
}

# Handle RIGHT command
handle_right() {
  local command="$1"
  local cmd_upper=$(echo "$command" | tr '[:lower:]' '[:upper:]')

  # Verify command format (case-insensitive)
  if ! [[ "$cmd_upper" =~ ^RIGHT[[:space:]]*$ ]]; then
    return 1
  fi

  rotate_right
}

# Handle REPORT command
handle_report() {
  local command="$1"
  local cmd_upper=$(echo "$command" | tr '[:lower:]' '[:upper:]')

  # Verify command format (case-insensitive)
  if ! [[ "$cmd_upper" =~ ^REPORT[[:space:]]*$ ]]; then
    return 1
  fi

  report_robot
}
