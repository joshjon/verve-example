# Toy Robot Simulator - Go Implementation Design

## Overview

This document outlines the design for implementing the Toy Robot Simulator in Go. The implementation follows clean architecture principles while avoiding over-engineering, focusing on clarity and maintainability.

## Architecture

### High-Level Structure

```
main.go
├── types.go         // Type definitions
├── robot.go         // Robot core logic
├── grid.go          // Grid/boundary logic
├── commands.go      // Command parsing and execution
├── input.go         // Input handling
└── tests/
    ├── robot_test.go
    ├── grid_test.go
    ├── commands_test.go
    └── integration_test.go
```

## Core Components

### 1. Types (`types.go`)

**Direction enum:**
```go
type Direction int

const (
    North Direction = iota
    East
    South
    West
)
```

**Position struct:**
```go
type Position struct {
    X, Y int
}
```

**Robot state:**
```go
type Robot struct {
    Position  Position
    Direction Direction
    Placed    bool  // Track if robot has been PLACE'd
}
```

**Command interface:**
```go
type Command interface {
    Execute(r *Robot) error
}
```

### 2. Robot Logic (`robot.go`)

**Responsibilities:**
- Manage robot state (position and direction)
- Implement movement calculations
- Implement rotation logic
- Provide read-only access to state via getters

**Key Methods:**
```go
func (r *Robot) Rotate(clockwise bool)      // LEFT (false) or RIGHT (true)
func (r *Robot) Move() (Position, bool)     // Returns new position and validity
func (r *Robot) Place(x, y int, d Direction) error
func (r *Robot) Status() string             // Returns "X,Y,F" format
```

**Design Decisions:**
- Robot struct is responsible for its own state integrity
- Movement validation returns the proposed position without modifying state; the caller (command handler) validates against grid boundaries
- Direction is cyclic: turning left/right rotates through the direction cycle

### 3. Grid Logic (`grid.go`)

**Responsibilities:**
- Define grid boundaries (5x5)
- Validate if a position is within bounds

**Key Functions:**
```go
func IsValidPosition(x, y int) bool
func GetGridDimensions() (width, height int)
```

**Design Decisions:**
- Grid is treated as a utility module, not a stateful component
- Boundaries are constants; they don't change during execution
- Separation of concerns: robot doesn't know about grid bounds; grid validation is separate

### 4. Command Parsing & Execution (`commands.go`)

**Command Types:**
```go
type PlaceCommand struct { X, Y int; Direction Direction }
type MoveCommand struct {}
type LeftCommand struct {}
type RightCommand struct {}
type ReportCommand struct {}
```

**Parser Function:**
```go
func ParseCommand(input string) (Command, error)
```

**Executor:**
```go
func Execute(r *Robot, cmd Command) (string, error)
```

**Design Decisions:**
- Each command is a separate type implementing a Command interface
- Parser returns errors for malformed input (e.g., "PLACE 1,2" missing direction)
- Executor handles silently ignoring invalid commands (out of bounds, commands before PLACE)
- REPORT returns the status string; other commands return empty string
- Invalid movements/placements don't raise errors; they're simply ignored with no output

### 5. Input Handling (`input.go`)

**Responsibilities:**
- Read commands from stdin or file
- Handle line-by-line processing
- Return errors only for I/O issues

**Key Functions:**
```go
func ReadCommands(reader io.Reader) chan string
func ProcessCommands(reader io.Reader, robot *Robot) []string
```

**Design Decisions:**
- Use channels for streaming input
- Distinguish between I/O errors (fail loudly) and invalid commands (fail silently)
- Support both stdin and file input via io.Reader interface

## Command Semantics

### Command Processing Rules

1. **PLACE X,Y,F**
   - If X,Y is outside grid: silently ignore
   - If F is invalid direction: silently ignore
   - First successful PLACE: robot is now on the table
   - Subsequent PLACE: reposition robot (if valid)

2. **MOVE**
   - If robot not placed: silently ignore
   - If move would go off table: silently ignore
   - Otherwise: move robot one unit forward

3. **LEFT**
   - If robot not placed: silently ignore
   - Rotate 90° counterclockwise

4. **RIGHT**
   - If robot not placed: silently ignore
   - Rotate 90° clockwise

5. **REPORT**
   - If robot not placed: silently ignore
   - Otherwise: output "X,Y,F" to stdout

## Implementation Strategy

### Phase 1: Core Logic
1. Implement types and constants
2. Implement robot state and methods
3. Implement grid validation
4. Write unit tests for robot and grid

### Phase 2: Command System
1. Implement command interface and types
2. Implement command parser
3. Implement command executor
4. Write unit tests for commands

### Phase 3: Integration
1. Implement input handler
2. Implement main entry point
3. Write integration tests
4. Handle edge cases

### Phase 4: Polish
1. Documentation and examples
2. Performance review (if needed)
3. Code review for clarity

## Testing Strategy

### Unit Tests

**Robot Tests:**
- Rotation logic (all directions, multiple rotations)
- Movement calculations (all directions, multiple moves)
- Placement and status reporting
- Boundary movement validation

**Grid Tests:**
- Valid and invalid positions
- Corner cases (negative, exceeds bounds)

**Command Tests:**
- Parse valid commands
- Parse invalid commands (malformed, unknown)
- Execute with robot not placed
- Execute with out-of-bounds movements
- State transitions (placement changes state)

**Parser Tests:**
- Case sensitivity (PLACE vs place)
- Whitespace handling
- Parameter validation

### Integration Tests

**Test Scenarios from README:**
```
# Example 1
PLACE 0,0,NORTH
MOVE
REPORT  → 0,1,NORTH

# Example 2
PLACE 0,0,NORTH
LEFT
REPORT  → 0,0,WEST
```

**Additional Scenarios:**
- Multiple PLACE commands (repositioning)
- Movement at boundaries (south at 0,0, east at 4,4, etc.)
- Commands before PLACE
- Rotation sequences (full circle)
- Complex command sequences

## Code Quality Principles

### Applied Throughout

1. **Clarity over cleverness**: Straightforward implementations preferred
2. **Single Responsibility**: Each type/function has one job
3. **Immutability where practical**: Position is immutable; Robot manages its own state
4. **Minimal error handling**: Errors only for true exceptional conditions (I/O, malformed commands)
5. **Testability**: Small, focused functions; dependency injection via parameters

### No Over-Engineering

- No dependency injection framework; standard Go packages only
- No abstract interfaces for single-implementation concepts
- No logging framework; use standard library or omit
- No configuration files; hardcoded 5x5 grid is appropriate
- Validation is inline where needed, not in separate validator classes

## Error Handling

### Categories

1. **Command Parsing Errors** (return error to user):
   - Malformed input: "PLACE 1,2" (missing direction)
   - Invalid direction: "PLACE 0,0,NORTHWEST"
   - Unknown command: "JUMP"

2. **Invalid Operations** (silently ignore):
   - MOVE/REPORT when robot not placed
   - PLACE outside grid bounds
   - MOVE that would go off table

3. **I/O Errors** (fail with error):
   - File not found
   - Read error

### Implementation Approach

```go
// Parser returns error for malformed input
cmd, err := ParseCommand(line)
if err != nil {
    // Log or report error
    continue
}

// Executor returns output or empty string, never errors
output, _ := Execute(robot, cmd)
if output != "" {
    fmt.Println(output)
}
```

## File Organization

```
robot-simulator/
├── main.go                          # Entry point
├── internal/
│   ├── robot.go                     # Robot core logic
│   ├── grid.go                      # Grid validation
│   ├── command.go                   # Command types and parser
│   ├── input.go                     # Input handling
│   └── types.go                     # Type definitions
├── cmd/
│   └── main.go                      # CLI wrapper (if needed)
├── test/
│   ├── robot_test.go
│   ├── command_test.go
│   ├── integration_test.go
│   └── testdata/                    # Test input files
├── README.md                        # Implementation guide
├── DESIGN.md                        # This file
└── go.mod                           # Go module file
```

## Execution Flow

```
main()
  ├─ Create Robot instance
  ├─ Open input reader (stdin or file)
  ├─ For each line of input:
  │  ├─ Parse command
  │  ├─ If parse error: report and continue
  │  ├─ Execute command with robot
  │  └─ If REPORT: print output
  └─ Exit cleanly
```

## Future Considerations (Out of Scope)

These are improvements that could be made but are not part of the current implementation:

1. **Undo/Redo**: Command history and rollback
2. **Batching**: Load commands from multiple files
3. **Validation Scripts**: Pre-check all commands before execution
4. **Performance Optimization**: Currently adequate for small grids
5. **Extended Grids**: Make grid dimensions configurable
6. **Obstacles**: Allow marking grid cells as obstacles
7. **Concurrent Robots**: Support multiple robots

## Success Criteria

1. ✅ **Correct Implementation**: All commands work as specified
2. ✅ **Clean Code**: Easy to read and understand
3. ✅ **Tested**: Good coverage of happy path and edge cases
4. ✅ **Documented**: Clear README with examples
5. ✅ **No Over-Engineering**: Simple, maintainable solution
