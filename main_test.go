package main

import (
	"testing"
)

func TestPlaceValid(t *testing.T) {
	r := &Robot{}
	if !r.Place(0, 0, NORTH) {
		t.Error("Place should succeed for valid position")
	}
	if r.X != 0 || r.Y != 0 || r.F != NORTH || !r.Placed {
		t.Error("Robot state not correctly set")
	}
}

func TestPlaceInvalid(t *testing.T) {
	r := &Robot{}
	if r.Place(5, 5, NORTH) {
		t.Error("Place should fail for invalid position")
	}
	if r.Placed {
		t.Error("Robot should not be marked as placed")
	}
}

func TestMoveNorth(t *testing.T) {
	r := &Robot{}
	r.Place(0, 0, NORTH)
	if !r.Move() {
		t.Error("Move should succeed")
	}
	if r.X != 0 || r.Y != 1 {
		t.Errorf("Expected (0,1), got (%d,%d)", r.X, r.Y)
	}
}

func TestMoveEast(t *testing.T) {
	r := &Robot{}
	r.Place(0, 0, EAST)
	if !r.Move() {
		t.Error("Move should succeed")
	}
	if r.X != 1 || r.Y != 0 {
		t.Errorf("Expected (1,0), got (%d,%d)", r.X, r.Y)
	}
}

func TestMoveSouth(t *testing.T) {
	r := &Robot{}
	r.Place(1, 1, SOUTH)
	if !r.Move() {
		t.Error("Move should succeed")
	}
	if r.X != 1 || r.Y != 0 {
		t.Errorf("Expected (1,0), got (%d,%d)", r.X, r.Y)
	}
}

func TestMoveWest(t *testing.T) {
	r := &Robot{}
	r.Place(1, 1, WEST)
	if !r.Move() {
		t.Error("Move should succeed")
	}
	if r.X != 0 || r.Y != 1 {
		t.Errorf("Expected (0,1), got (%d,%d)", r.X, r.Y)
	}
}

func TestMoveBoundaryNorth(t *testing.T) {
	r := &Robot{}
	r.Place(0, 4, NORTH)
	if r.Move() {
		t.Error("Move should fail at boundary")
	}
	if r.X != 0 || r.Y != 4 {
		t.Error("Robot should not move past boundary")
	}
}

func TestMoveBoundaryWest(t *testing.T) {
	r := &Robot{}
	r.Place(0, 0, WEST)
	if r.Move() {
		t.Error("Move should fail at boundary")
	}
	if r.X != 0 || r.Y != 0 {
		t.Error("Robot should not move past boundary")
	}
}

func TestTurnLeft(t *testing.T) {
	r := &Robot{}
	r.Place(0, 0, NORTH)
	r.TurnLeft()
	if r.F != WEST {
		t.Errorf("Expected WEST, got %s", r.F)
	}
}

func TestTurnRight(t *testing.T) {
	r := &Robot{}
	r.Place(0, 0, NORTH)
	r.TurnRight()
	if r.F != EAST {
		t.Errorf("Expected EAST, got %s", r.F)
	}
}

func TestReport(t *testing.T) {
	r := &Robot{}
	r.Place(2, 3, NORTH)
	report := r.Report()
	if report != "2,3,NORTH" {
		t.Errorf("Expected '2,3,NORTH', got '%s'", report)
	}
}

func TestReportNotPlaced(t *testing.T) {
	r := &Robot{}
	report := r.Report()
	if report != "" {
		t.Errorf("Expected empty string, got '%s'", report)
	}
}

func TestParseDirection(t *testing.T) {
	tests := []struct {
		input    string
		expected Direction
		wantErr  bool
	}{
		{"NORTH", NORTH, false},
		{"EAST", EAST, false},
		{"SOUTH", SOUTH, false},
		{"WEST", WEST, false},
		{"north", NORTH, false},
		{"East", EAST, false},
		{"INVALID", NORTH, true},
	}

	for _, test := range tests {
		d, err := ParseDirection(test.input)
		if (err != nil) != test.wantErr {
			t.Errorf("ParseDirection(%s) error = %v, wantErr %v", test.input, err, test.wantErr)
		}
		if !test.wantErr && d != test.expected {
			t.Errorf("ParseDirection(%s) = %v, expected %v", test.input, d, test.expected)
		}
	}
}

func TestComplexScenario(t *testing.T) {
	r := &Robot{}

	// PLACE 1,2,NORTH
	r.Place(1, 2, NORTH)
	// MOVE
	r.Move()
	if r.X != 1 || r.Y != 3 {
		t.Errorf("After MOVE, expected (1,3), got (%d,%d)", r.X, r.Y)
	}
	// LEFT
	r.TurnLeft()
	if r.F != WEST {
		t.Errorf("After LEFT, expected WEST, got %s", r.F)
	}
	// MOVE
	r.Move()
	if r.X != 0 || r.Y != 3 {
		t.Errorf("After MOVE, expected (0,3), got (%d,%d)", r.X, r.Y)
	}
	// MOVE
	r.Move()
	if r.X != -1 {
		t.Errorf("MOVE should fail at boundary, but position is (%d,%d)", r.X, r.Y)
	}
	// RIGHT
	r.TurnRight()
	if r.F != NORTH {
		t.Errorf("After RIGHT, expected NORTH, got %s", r.F)
	}
	// RIGHT
	r.TurnRight()
	if r.F != EAST {
		t.Errorf("After RIGHT, expected EAST, got %s", r.F)
	}
	// MOVE
	r.Move()
	if r.X != 1 || r.Y != 3 {
		t.Errorf("After MOVE, expected (1,3), got (%d,%d)", r.X, r.Y)
	}
	// MOVE
	r.Move()
	if r.X != 2 || r.Y != 3 {
		t.Errorf("After MOVE, expected (2,3), got (%d,%d)", r.X, r.Y)
	}
}
