# Toy Robot Simulator - Implementation Solution

## Problem Summary

Implement a toy robot simulator for a 5x5 square tabletop that:
- Accepts text-based commands (PLACE, MOVE, LEFT, RIGHT, REPORT)
- Prevents the robot from falling off the table
- Maintains robot state (position and facing direction)
- Reports robot position and direction on command

## Solution Architecture

### 1. Core Data Model

**Robot State:**
- **Position**: Coordinates (x, y) where 0 ≤ x, y ≤ 4
- **Direction**: One of NORTH, SOUTH, EAST, WEST
- **Placed**: Boolean flag indicating if robot has been validly placed

**Tabletop:**
- Fixed 5x5 grid
- Origin (0,0) at SOUTH WEST corner
- Valid positions: (0,0) to (4,4)

### 2. Implementation Approach

#### 2.1 Direction Handling
Create a direction mapping system:
- Map each direction to coordinate deltas: NORTH=(0,1), SOUTH=(0,-1), EAST=(1,0), WEST=(-1,0)
- Use array-based rotation for LEFT/RIGHT commands
- Maintain order: [NORTH, EAST, SOUTH, WEST] for 90-degree rotations

#### 2.2 Command Parser
Implement a robust command parser that:
- Splits input by newlines and trims whitespace
- Extracts command name and parameters
- Validates command format before execution
- Handles case-insensitive input (PLACE vs place)

#### 2.3 Robot Controller
Create the main robot class with methods:
- `place(x, y, direction)` - Set initial position/direction with validation
- `move()` - Move forward if not hitting boundary
- `leftTurn()` - Rotate 90° counter-clockwise
- `rightTurn()` - Rotate 90° clockwise
- `report()` - Return current position and direction

**Validation Rules:**
- PLACE command must be received before any other command is executed
- Ignore PLACE if x,y coordinates are outside [0,4] range
- Ignore MOVE if it would move robot outside [0,4] range
- Other commands have no pre-conditions once placed

#### 2.4 Boundary Checking
Before executing MOVE:
1. Calculate new position: `newX = x + deltaX`, `newY = y + deltaY`
2. Check if `0 ≤ newX ≤ 4` and `0 ≤ newY ≤ 4`
3. Only update position if valid

### 3. Code Structure

```
Project Structure:
├── src/
│   ├── Robot.js          # Core robot class
│   ├── Direction.js      # Direction enum/constants
│   ├── CommandParser.js  # Input parsing logic
│   └── simulator.js      # Main entry point
├── tests/
│   ├── Robot.test.js     # Robot state tests
│   ├── CommandParser.test.js
│   └── Integration.test.js
├── README.md             # Updated with implementation details
├── package.json          # Dependencies (Jest for testing)
└── main.sh              # Shell wrapper (optional)
```

### 4. Implementation Strategy

#### Phase 1: Foundation
1. Create Direction constants and mapping (NORTH→(0,1), EAST→(1,0), etc.)
2. Implement Robot class with state management
3. Add boundary validation utility functions

#### Phase 2: Core Logic
1. Implement PLACE command with validation
2. Implement MOVE with boundary checking
3. Implement LEFT/RIGHT rotation
4. Implement REPORT output

#### Phase 3: Integration
1. Create CommandParser to tokenize and validate input
2. Wire commands to Robot methods
3. Handle command execution flow (PLACE requirement)

#### Phase 4: Testing
1. Unit tests for each robot method
2. Integration tests for command sequences
3. Edge case tests (boundary conditions, invalid inputs)

### 5. Key Design Decisions

**1. Direction as Array Index**
- Store directions in array: `['NORTH', 'EAST', 'SOUTH', 'WEST']`
- Use modulo arithmetic for rotation: `(currentIndex + 1) % 4` for RIGHT
- Pro: Simple, efficient rotation logic
- Con: Less explicit than switch statements

**2. Placed Flag Pattern**
- Track whether robot has received valid PLACE command
- Ignore all commands except PLACE until placed
- Pro: Clear state machine, prevents invalid operations
- Con: Slight additional state to maintain

**3. Silent Failure on Invalid Operations**
- Invalid MOVE/PLACE commands are ignored, no error thrown
- Aligns with requirements: "the robot can be prevented from moving"
- Pro: Simple, matches specification
- Con: May hide user input errors (acceptable for this use case)

**4. Immutable Command Execution**
- Each command modifies robot state independently
- No transaction/rollback needed
- Pro: Simple, no side effects across commands
- Con: Can't undo commands (not required)

### 6. Testing Strategy

**Unit Tests:**
```javascript
// Robot class
- test PLACE with valid/invalid coordinates
- test MOVE in each direction
- test MOVE at boundaries (shouldn't move)
- test LEFT/RIGHT rotation
- test REPORT output format
- test operations before PLACE (should be ignored)

// Direction handling
- test all direction mappings
- test rotation sequences

// CommandParser
- test command tokenization
- test parameter extraction
- test case insensitivity
- test malformed input handling
```

**Integration Tests:**
```javascript
// Complete scenarios from spec
- PLACE 0,0,NORTH → MOVE → REPORT = 0,1,NORTH
- PLACE 0,0,NORTH → LEFT → REPORT = 0,0,WEST
- PLACE 1,2,EAST → MOVE → MOVE → LEFT → MOVE → REPORT = 3,3,NORTH
```

### 7. Output Format

REPORT command outputs: `X,Y,DIRECTION`
- Example: `0,1,NORTH`
- No extra spaces or formatting
- One report per REPORT command

### 8. Input Processing

**Valid Input Format:**
```
PLACE X,Y,DIRECTION
MOVE
LEFT
RIGHT
REPORT
```

**Assumptions:**
- Commands are separated by newlines
- X,Y in PLACE are comma-separated, space-separated from direction
- Whitespace is trimmed
- Input is case-insensitive
- Unknown commands are ignored

### 9. Technology Choice: JavaScript/Node.js

**Rationale:**
- .gitignore indicates JavaScript project
- Jest framework for testing (industry standard)
- Easy to run with Node.js interpreter
- Good for script-like CLI applications
- Simple to create executable entry point

**Alternative:** TypeScript (adds type safety but more setup)

### 10. Error Handling

**No exceptions thrown for:**
- Invalid MOVE (would fall off table) → silently ignored
- Invalid PLACE (outside bounds) → silently ignored
- MOVE/LEFT/RIGHT before PLACE → silently ignored
- Unknown commands → silently ignored

**Only returns:**
- REPORT output on REPORT command
- No error messages (per specification)

## Implementation Complexity

**Low Complexity:**
- Small problem domain (5x5 grid, 4 directions, 5 commands)
- Simple state machine (placed vs not placed)
- No external dependencies needed

**Estimated Lines of Code:**
- Robot class: ~50-100 lines
- CommandParser: ~40-80 lines
- Tests: ~200-300 lines
- Total: ~300-500 lines

## What Could Be Improved With More Time

1. **TypeScript**: Add type safety and better IDE support
2. **CLI Interface**: Interactive mode where user enters commands
3. **Visualization**: ASCII visualization of robot on grid
4. **Configuration**: Make tabletop size configurable
5. **Logging**: Debug mode to show all state transitions
6. **Performance**: Caching for direction mappings (overkill for 5x5)
7. **Documentation**: Detailed JSDoc comments
8. **Error Reporting**: Validation error messages for debugging

## Implementation Assumptions

1. Commands are valid tokens (will be validated)
2. PLACE format is strict: `PLACE X,Y,DIRECTION` (no variations)
3. Single robot instance per simulator
4. No multi-robot scenarios
5. All input comes from stdin or string buffer (not real-time)
6. No persistence or state save/load needed
7. No concurrent command processing
8. Grid is always 5x5 (not configurable)

## Success Criteria

✅ All 5 commands work correctly
✅ Boundary checking prevents invalid moves
✅ Robot won't execute commands before PLACE
✅ REPORT outputs correct format
✅ Invalid PLACE commands are ignored
✅ All test scenarios pass
✅ Code is clean and readable
✅ README documents the solution
