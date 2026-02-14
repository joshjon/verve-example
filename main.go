package main

import (
	"bufio"
	"flag"
	"fmt"
	"os"
	"strings"
)

// Direction represents the cardinal directions the robot can face
type Direction int

const (
	NORTH Direction = iota
	EAST
	SOUTH
	WEST
)

// Robot represents the toy robot on the grid
type Robot struct {
	X        int
	Y        int
	F        Direction
	Placed   bool
}

// String returns the string representation of a direction
func (d Direction) String() string {
	switch d {
	case NORTH:
		return "NORTH"
	case EAST:
		return "EAST"
	case SOUTH:
		return "SOUTH"
	case WEST:
		return "WEST"
	default:
		return "UNKNOWN"
	}
}

// ParseDirection converts a string to a Direction
func ParseDirection(s string) (Direction, error) {
	switch strings.ToUpper(s) {
	case "NORTH":
		return NORTH, nil
	case "EAST":
		return EAST, nil
	case "SOUTH":
		return SOUTH, nil
	case "WEST":
		return WEST, nil
	default:
		return NORTH, fmt.Errorf("invalid direction: %s", s)
	}
}

// IsValidPosition checks if a position is within the 5x5 grid
func IsValidPosition(x, y int) bool {
	return x >= 0 && x <= 4 && y >= 0 && y <= 4
}

// Place sets the robot's position and direction
func (r *Robot) Place(x, y int, f Direction) bool {
	if !IsValidPosition(x, y) {
		return false
	}
	r.X = x
	r.Y = y
	r.F = f
	r.Placed = true
	return true
}

// Move advances the robot one unit in its facing direction
func (r *Robot) Move() bool {
	if !r.Placed {
		return false
	}

	var newX, newY int

	switch r.F {
	case NORTH:
		newX, newY = r.X, r.Y+1
	case EAST:
		newX, newY = r.X+1, r.Y
	case SOUTH:
		newX, newY = r.X, r.Y-1
	case WEST:
		newX, newY = r.X-1, r.Y
	}

	if !IsValidPosition(newX, newY) {
		return false
	}

	r.X = newX
	r.Y = newY
	return true
}

// TurnLeft rotates the robot 90 degrees counter-clockwise
func (r *Robot) TurnLeft() bool {
	if !r.Placed {
		return false
	}
	r.F = (r.F + 3) % 4 // Equivalent to -1 mod 4
	return true
}

// TurnRight rotates the robot 90 degrees clockwise
func (r *Robot) TurnRight() bool {
	if !r.Placed {
		return false
	}
	r.F = (r.F + 1) % 4
	return true
}

// Report returns the robot's current position and direction
func (r *Robot) Report() string {
	if !r.Placed {
		return ""
	}
	return fmt.Sprintf("%d,%d,%s", r.X, r.Y, r.F)
}

// ProcessCommand processes a single command
func (r *Robot) ProcessCommand(cmd string) {
	parts := strings.Fields(strings.TrimSpace(cmd))
	if len(parts) == 0 {
		return
	}

	command := strings.ToUpper(parts[0])

	switch command {
	case "PLACE":
		if len(parts) != 2 {
			return
		}
		coords := strings.Split(parts[1], ",")
		if len(coords) != 3 {
			return
		}

		var x, y int
		var f Direction
		var err error

		_, err = fmt.Sscanf(coords[0], "%d", &x)
		if err != nil {
			return
		}
		_, err = fmt.Sscanf(coords[1], "%d", &y)
		if err != nil {
			return
		}
		f, err = ParseDirection(coords[2])
		if err != nil {
			return
		}

		r.Place(x, y, f)

	case "MOVE":
		r.Move()

	case "LEFT":
		r.TurnLeft()

	case "RIGHT":
		r.TurnRight()

	case "REPORT":
		if output := r.Report(); output != "" {
			fmt.Println(output)
		}
	}
}

func main() {
	inputFile := flag.String("f", "", "input file (reads from stdin if not provided)")
	flag.Parse()

	robot := &Robot{}

	var scanner *bufio.Scanner
	if *inputFile != "" {
		file, err := os.Open(*inputFile)
		if err != nil {
			fmt.Fprintf(os.Stderr, "error opening file: %v\n", err)
			os.Exit(1)
		}
		defer file.Close()
		scanner = bufio.NewScanner(file)
	} else {
		scanner = bufio.NewScanner(os.Stdin)
	}

	for scanner.Scan() {
		line := scanner.Text()
		robot.ProcessCommand(line)
	}

	if err := scanner.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "error reading input: %v\n", err)
		os.Exit(1)
	}
}
