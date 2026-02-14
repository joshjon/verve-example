#!/bin/bash

# Test Suite for Toy Robot Simulation
# Run with: bash tests/test.sh

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "${SCRIPT_DIR}/src/robot.sh"
source "${SCRIPT_DIR}/src/command-parser.sh"

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Reset robot state before each test
reset_robot() {
  ROBOT_X=
  ROBOT_Y=
  ROBOT_DIRECTION=
  ROBOT_PLACED=false
}

# Assert function
assert_equals() {
  local expected="$1"
  local actual="$2"
  local test_name="$3"

  ((TESTS_RUN++))

  if [[ "$expected" == "$actual" ]]; then
    echo "✓ $test_name"
    ((TESTS_PASSED++))
  else
    echo "✗ $test_name"
    echo "  Expected: $expected"
    echo "  Actual: $actual"
    ((TESTS_FAILED++))
  fi
}

# Assert function for exit codes
assert_success() {
  local test_name="$1"

  ((TESTS_RUN++))

  if [[ $? -eq 0 ]]; then
    echo "✓ $test_name"
    ((TESTS_PASSED++))
  else
    echo "✗ $test_name"
    ((TESTS_FAILED++))
  fi
}

# Test: Place robot at origin facing north
test_place_at_origin() {
  reset_robot
  place_robot 0 0 NORTH
  assert_equals "0" "$ROBOT_X" "Robot X position after place"
  assert_equals "0" "$ROBOT_Y" "Robot Y position after place"
  assert_equals "NORTH" "$ROBOT_DIRECTION" "Robot direction after place"
}

# Test: Place robot at top-right corner
test_place_at_corner() {
  reset_robot
  place_robot 4 4 SOUTH
  assert_equals "4" "$ROBOT_X" "Robot X at corner"
  assert_equals "4" "$ROBOT_Y" "Robot Y at corner"
  assert_equals "SOUTH" "$ROBOT_DIRECTION" "Robot direction at corner"
}

# Test: Reject invalid placement (out of bounds)
test_place_out_of_bounds() {
  reset_robot
  place_robot 5 0 NORTH
  assert_equals "false" "$ROBOT_PLACED" "Robot should not be placed out of bounds"
}

# Test: Move robot north
test_move_north() {
  reset_robot
  place_robot 0 0 NORTH
  move_robot
  assert_equals "0" "$ROBOT_X" "X unchanged after move north"
  assert_equals "1" "$ROBOT_Y" "Y increased after move north"
}

# Test: Move robot east
test_move_east() {
  reset_robot
  place_robot 0 0 EAST
  move_robot
  assert_equals "1" "$ROBOT_X" "X increased after move east"
  assert_equals "0" "$ROBOT_Y" "Y unchanged after move east"
}

# Test: Move robot south
test_move_south() {
  reset_robot
  place_robot 2 2 SOUTH
  move_robot
  assert_equals "2" "$ROBOT_X" "X unchanged after move south"
  assert_equals "1" "$ROBOT_Y" "Y decreased after move south"
}

# Test: Move robot west
test_move_west() {
  reset_robot
  place_robot 2 2 WEST
  move_robot
  assert_equals "1" "$ROBOT_X" "X decreased after move west"
  assert_equals "2" "$ROBOT_Y" "Y unchanged after move west"
}

# Test: Prevent falling off north edge
test_prevent_fall_north() {
  reset_robot
  place_robot 0 4 NORTH
  move_robot
  assert_equals "0" "$ROBOT_X" "X unchanged at north edge"
  assert_equals "4" "$ROBOT_Y" "Y unchanged at north edge (prevented fall)"
}

# Test: Prevent falling off south edge
test_prevent_fall_south() {
  reset_robot
  place_robot 0 0 SOUTH
  move_robot
  assert_equals "0" "$ROBOT_X" "X unchanged at south edge"
  assert_equals "0" "$ROBOT_Y" "Y unchanged at south edge (prevented fall)"
}

# Test: Prevent falling off east edge
test_prevent_fall_east() {
  reset_robot
  place_robot 4 0 EAST
  move_robot
  assert_equals "4" "$ROBOT_X" "X unchanged at east edge (prevented fall)"
  assert_equals "0" "$ROBOT_Y" "Y unchanged at east edge"
}

# Test: Prevent falling off west edge
test_prevent_fall_west() {
  reset_robot
  place_robot 0 0 WEST
  move_robot
  assert_equals "0" "$ROBOT_X" "X unchanged at west edge (prevented fall)"
  assert_equals "0" "$ROBOT_Y" "Y unchanged at west edge"
}

# Test: Rotate left from north
test_rotate_left_from_north() {
  reset_robot
  place_robot 0 0 NORTH
  rotate_left
  assert_equals "WEST" "$ROBOT_DIRECTION" "Rotate left from north"
}

# Test: Rotate left from east
test_rotate_left_from_east() {
  reset_robot
  place_robot 0 0 EAST
  rotate_left
  assert_equals "NORTH" "$ROBOT_DIRECTION" "Rotate left from east"
}

# Test: Rotate left from south
test_rotate_left_from_south() {
  reset_robot
  place_robot 0 0 SOUTH
  rotate_left
  assert_equals "EAST" "$ROBOT_DIRECTION" "Rotate left from south"
}

# Test: Rotate left from west
test_rotate_left_from_west() {
  reset_robot
  place_robot 0 0 WEST
  rotate_left
  assert_equals "SOUTH" "$ROBOT_DIRECTION" "Rotate left from west"
}

# Test: Rotate right from north
test_rotate_right_from_north() {
  reset_robot
  place_robot 0 0 NORTH
  rotate_right
  assert_equals "EAST" "$ROBOT_DIRECTION" "Rotate right from north"
}

# Test: Rotate right from east
test_rotate_right_from_east() {
  reset_robot
  place_robot 0 0 EAST
  rotate_right
  assert_equals "SOUTH" "$ROBOT_DIRECTION" "Rotate right from east"
}

# Test: Rotate right from south
test_rotate_right_from_south() {
  reset_robot
  place_robot 0 0 SOUTH
  rotate_right
  assert_equals "WEST" "$ROBOT_DIRECTION" "Rotate right from south"
}

# Test: Rotate right from west
test_rotate_right_from_west() {
  reset_robot
  place_robot 0 0 WEST
  rotate_right
  assert_equals "NORTH" "$ROBOT_DIRECTION" "Rotate right from west"
}

# Test: Full rotation cycle left
test_full_rotation_left() {
  reset_robot
  place_robot 0 0 NORTH
  rotate_left
  rotate_left
  rotate_left
  rotate_left
  assert_equals "NORTH" "$ROBOT_DIRECTION" "Full rotation left returns to north"
}

# Test: Full rotation cycle right
test_full_rotation_right() {
  reset_robot
  place_robot 0 0 NORTH
  rotate_right
  rotate_right
  rotate_right
  rotate_right
  assert_equals "NORTH" "$ROBOT_DIRECTION" "Full rotation right returns to north"
}

# Test: Report position
test_report() {
  reset_robot
  place_robot 1 2 EAST
  local report_output=$(report_robot)
  assert_equals "1,2,EAST" "$report_output" "Report robot position"
}

# Test: Scenario 1 from README
test_scenario_1() {
  reset_robot
  place_robot 0 0 NORTH
  move_robot
  local report_output=$(report_robot)
  assert_equals "0,1,NORTH" "$report_output" "Scenario 1: PLACE 0,0,NORTH; MOVE; REPORT"
}

# Test: Scenario 2 from README
test_scenario_2() {
  reset_robot
  place_robot 0 0 NORTH
  rotate_left
  local report_output=$(report_robot)
  assert_equals "0,0,WEST" "$report_output" "Scenario 2: PLACE 0,0,NORTH; LEFT; REPORT"
}

# Test: Complex sequence
test_complex_sequence() {
  reset_robot
  place_robot 1 2 NORTH
  move_robot
  rotate_right
  move_robot
  rotate_right
  move_robot
  rotate_right
  move_robot
  rotate_right
  move_robot
  local report_output=$(report_robot)
  assert_equals "1,3,NORTH" "$report_output" "Complex sequence traces square and moves forward"
}

# Test: Move before place (should fail)
test_move_before_place() {
  reset_robot
  ((TESTS_RUN++))
  if ! move_robot 2>/dev/null; then
    echo "✓ Move before place fails correctly"
    ((TESTS_PASSED++))
  else
    echo "✗ Move before place should fail"
    ((TESTS_FAILED++))
  fi
}

# Test: Command parser - valid PLACE
test_parser_place() {
  reset_robot
  parse_command "PLACE 2,3,SOUTH"
  assert_equals "2" "$ROBOT_X" "Parser places robot at X"
  assert_equals "3" "$ROBOT_Y" "Parser places robot at Y"
  assert_equals "SOUTH" "$ROBOT_DIRECTION" "Parser sets direction"
}

# Test: Command parser - case insensitive
test_parser_case_insensitive() {
  reset_robot
  parse_command "place 1,1,NORTH"
  assert_equals "1" "$ROBOT_X" "Parser handles lowercase place"
}

# Test: Command parser - MOVE
test_parser_move() {
  reset_robot
  place_robot 0 0 NORTH
  parse_command "MOVE"
  assert_equals "0" "$ROBOT_X" "Parser MOVE command X"
  assert_equals "1" "$ROBOT_Y" "Parser MOVE command Y"
}

# Test: Command parser - LEFT
test_parser_left() {
  reset_robot
  place_robot 0 0 NORTH
  parse_command "LEFT"
  assert_equals "WEST" "$ROBOT_DIRECTION" "Parser LEFT command"
}

# Test: Command parser - RIGHT
test_parser_right() {
  reset_robot
  place_robot 0 0 NORTH
  parse_command "RIGHT"
  assert_equals "EAST" "$ROBOT_DIRECTION" "Parser RIGHT command"
}

# Test: Invalid direction
test_invalid_direction() {
  reset_robot
  place_robot 0 0 INVALID
  assert_equals "false" "$ROBOT_PLACED" "Reject invalid direction"
}

# Test: Invalid coordinates (negative)
test_invalid_negative_coords() {
  reset_robot
  place_robot -1 0 NORTH
  assert_equals "false" "$ROBOT_PLACED" "Reject negative coordinates"
}

# Run all tests
echo "Running Toy Robot Simulation Tests"
echo "=================================="
echo ""

test_place_at_origin
test_place_at_corner
test_place_out_of_bounds
test_move_north
test_move_east
test_move_south
test_move_west
test_prevent_fall_north
test_prevent_fall_south
test_prevent_fall_east
test_prevent_fall_west
test_rotate_left_from_north
test_rotate_left_from_east
test_rotate_left_from_south
test_rotate_left_from_west
test_rotate_right_from_north
test_rotate_right_from_east
test_rotate_right_from_south
test_rotate_right_from_west
test_full_rotation_left
test_full_rotation_right
test_report
test_scenario_1
test_scenario_2
test_complex_sequence
test_move_before_place
test_parser_place
test_parser_case_insensitive
test_parser_move
test_parser_left
test_parser_right
test_invalid_direction
test_invalid_negative_coords

echo ""
echo "=================================="
echo "Test Results: $TESTS_PASSED/$TESTS_RUN passed"

if [[ $TESTS_FAILED -gt 0 ]]; then
  echo "Failed tests: $TESTS_FAILED"
  exit 1
fi

exit 0
