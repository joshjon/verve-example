# Toy Robot Simulation Coding Challenge

## Overview

This challenge involves creating a simulation of a toy robot moving on a square tabletop of dimensions 5x5 units. Your task is to develop an application that can read and execute specific commands, maintaining the toy robot within the confines of the tabletop.

## Requirements

- The robot should move within a 5x5 square tabletop.
- No obstructions exist on the tabletop surface.
- Prevent the robot from "falling" off the tabletop.
- The robot should interpret the following commands:
    - PLACE X,Y,F
    - MOVE
    - LEFT
    - RIGHT
    - REPORT

**Command Details:**

- PLACE will put the robot on the table at position X,Y and facing NORTH, SOUTH, EAST or WEST.
- The origin (0,0) is the SOUTH WEST most corner.
- The first valid command is a PLACE command.
- Commands can be issued in any order, including another PLACE command.
- MOVE will move the robot one unit forward in the direction it is currently facing.
- LEFT and RIGHT will rotate the robot 90 degrees in the specified direction without changing its position.
- REPORT will announce the X,Y and F of the robot through the standard output.

## Constraints

Prevent the robot from falling off the table. This also includes the initial placement of the toy robot. Any movement that would cause the robot to fall must be ignored.

## Sample Input and Output

### a) Scenario 1

```
PLACE 0,0,NORTH
MOVE
REPORT
```

Output: `0,1,NORTH`

### b) Scenario 2

```
PLACE 0,0,NORTH
LEFT
REPORT
```

Output: `0,0,WEST`

## Deliverables

- GitHub repository containing your solution in your preferred programming language.
- Instructions on how to run your project.
- Unit tests demonstrating the functionality of your application.

This can be a Command Line Interface (CLI) application OR a User Interface (UI) application that showcases your skills. The emphasis is on the implementation of the logic with clean, readable code.

## **What we would like to see**

1. **Functionality:** Your solution should correctly implement the toy robot simulation as per the given requirements and constraints.
2. **Code Quality:** Your code should be clean, well-structured, and easy to read. Make good use of comments where necessary, but we’d like to code that’s self-describing.
3. **Testing:** Include as many tests as you deem appropriate to demonstrate that your solution works correctly. We don’t follow strict TDD at Mr Yum, and we’re interested in hearing your opinions on testing.
4. **Problem Solving:** We're interested in how you approach problems and how you solve them. There are no right answers here - only tradeoffs. So, feel free to document them.

## The most successful candidates usually

1. Write a good README.
2. Make the tradeoffs clear in the code, or in the README.
3. Have consistency in naming, and structuring their code.
4. Don't over-engineer their solution.
    1. Instead, they can tell what they could've done, if afforded more time.
5. Code in the language they're most comfortable in.

## Implementation Plan

### 1. Core Data Structures

**Robot State**
- Maintain the robot's position as (X, Y) coordinates
- Track the robot's facing direction (NORTH, SOUTH, EAST, WEST)
- Store whether the robot has been placed on the table

**Table Bounds**
- Define the 5x5 grid boundaries (0-4 for both X and Y)
- Validate coordinates against these bounds

### 2. Direction and Movement Logic

**Direction Management**
- Create a direction enum or set of constants: NORTH, SOUTH, EAST, WEST
- Map each direction to its coordinate deltas (e.g., NORTH = (0, 1))
- Implement rotation logic for LEFT and RIGHT commands
  - LEFT: NORTH → WEST → SOUTH → EAST → NORTH
  - RIGHT: NORTH → EAST → SOUTH → WEST → NORTH

**Movement Validation**
- Before moving, calculate the new position based on current direction
- Check if the new position stays within table bounds (0 ≤ X ≤ 4 and 0 ≤ Y ≤ 4)
- Only update robot position if the move is valid; ignore invalid moves

### 3. Command Processing

**PLACE Command**
- Parse X, Y, and facing direction from input
- Validate that X and Y are within bounds
- Reject if not on the table yet (for initial placement)
- Set robot position and direction

**MOVE Command**
- Only execute if the robot is on the table
- Calculate new position based on current direction
- Validate bounds before moving
- Update position if valid, ignore otherwise

**LEFT and RIGHT Commands**
- Only execute if the robot is on the table
- Rotate the facing direction without moving the position

**REPORT Command**
- Only execute if the robot is on the table
- Output the current X, Y, and facing direction in format: `X,Y,F`

### 4. Input Handling

**Command Parser**
- Read commands line by line from input (stdin or file)
- Handle whitespace and case variations
- Parse the PLACE command format: `PLACE X,Y,F`
- Validate command syntax (ignore malformed commands)

**Execution Flow**
- Process commands sequentially
- Ignore any command before the first valid PLACE
- Continue processing remaining commands even if some are invalid

### 5. Testing Strategy

**Unit Tests to Consider**
- PLACE command with valid coordinates
- PLACE command with out-of-bounds coordinates
- MOVE command in all four directions
- MOVE command at table edges (boundary conditions)
- LEFT and RIGHT rotations
- REPORT command output verification
- Invalid commands and edge cases
- Multiple PLACE commands (robot repositioning)

**Test Scenarios**
- Implement at least the two provided examples
- Add edge cases: corner placements, multiple moves, direction changes

### 6. Code Organization

**Suggested Structure**
- Robot class/struct to encapsulate robot state and behavior
- Table or Grid class to manage bounds and validation
- Command processor/parser to handle input and execute commands
- Main application entry point to orchestrate the flow
- Separate test files for unit testing

### 7. Deliverables Checklist

- [ ] Working implementation of toy robot simulation
- [ ] Unit tests covering main functionality and edge cases
- [ ] Clear instructions on how to run the application
- [ ] Documentation of any design decisions or tradeoffs
- [ ] Clean, readable, and well-structured code
