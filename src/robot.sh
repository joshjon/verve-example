#!/bin/bash

# Robot Simulation Logic
# Handles robot state management, movement, and rotation

# Directions in order: NORTH, EAST, SOUTH, WEST
declare -a DIRECTIONS=(NORTH EAST SOUTH WEST)

# Direction vectors: each direction is [dx, dy]
declare -A DIRECTION_VECTORS=(
  [NORTH]="0 1"
  [EAST]="1 0"
  [SOUTH]="0 -1"
  [WEST]="-1 0"
)

# Place the robot on the table
# Args: x, y, direction
# Returns: 0 if placed successfully, 1 if placement is invalid
place_robot() {
  local x=$1
  local y=$2
  local direction=$3

  # Validate coordinates
  if ! is_valid_position "$x" "$y"; then
    return 1
  fi

  # Validate direction
  if ! is_valid_direction "$direction"; then
    return 1
  fi

  ROBOT_X=$x
  ROBOT_Y=$y
  ROBOT_DIRECTION=$direction
  ROBOT_PLACED=true

  return 0
}

# Move the robot one unit forward in its current direction
# Returns: 0 if moved successfully, 1 if movement would go off table
move_robot() {
  if [[ "$ROBOT_PLACED" != true ]]; then
    return 1
  fi

  read -r dx dy <<< "${DIRECTION_VECTORS[$ROBOT_DIRECTION]}"

  local new_x=$((ROBOT_X + dx))
  local new_y=$((ROBOT_Y + dy))

  # Check if new position is valid
  if ! is_valid_position "$new_x" "$new_y"; then
    return 1
  fi

  ROBOT_X=$new_x
  ROBOT_Y=$new_y

  return 0
}

# Rotate the robot left (counter-clockwise)
rotate_left() {
  if [[ "$ROBOT_PLACED" != true ]]; then
    return 1
  fi

  local current_index
  for i in "${!DIRECTIONS[@]}"; do
    if [[ "${DIRECTIONS[$i]}" == "$ROBOT_DIRECTION" ]]; then
      current_index=$i
      break
    fi
  done

  # Rotate left (counter-clockwise): index - 1, wrap around if needed
  local new_index=$(((current_index - 1 + 4) % 4))
  ROBOT_DIRECTION="${DIRECTIONS[$new_index]}"

  return 0
}

# Rotate the robot right (clockwise)
rotate_right() {
  if [[ "$ROBOT_PLACED" != true ]]; then
    return 1
  fi

  local current_index
  for i in "${!DIRECTIONS[@]}"; do
    if [[ "${DIRECTIONS[$i]}" == "$ROBOT_DIRECTION" ]]; then
      current_index=$i
      break
    fi
  done

  # Rotate right (clockwise): index + 1, wrap around if needed
  local new_index=$(((current_index + 1) % 4))
  ROBOT_DIRECTION="${DIRECTIONS[$new_index]}"

  return 0
}

# Report the current position and direction of the robot
report_robot() {
  if [[ "$ROBOT_PLACED" != true ]]; then
    return 1
  fi

  echo "${ROBOT_X},${ROBOT_Y},${ROBOT_DIRECTION}"
  return 0
}

# Check if a position is valid (within 5x5 table bounds)
# Args: x, y
# Returns: 0 if valid, 1 if invalid
is_valid_position() {
  local x=$1
  local y=$2

  # Check if x and y are numbers
  if ! [[ "$x" =~ ^[0-9]+$ && "$y" =~ ^[0-9]+$ ]]; then
    return 1
  fi

  # Check if within bounds (0-4 inclusive for a 5x5 table)
  if (( x >= 0 && x <= 4 && y >= 0 && y <= 4 )); then
    return 0
  fi

  return 1
}

# Check if a direction is valid
# Args: direction
# Returns: 0 if valid, 1 if invalid
is_valid_direction() {
  local direction=$1

  for dir in "${DIRECTIONS[@]}"; do
    if [[ "$dir" == "$direction" ]]; then
      return 0
    fi
  done

  return 1
}
