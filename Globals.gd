extends Node

enum Direction {
	ACROSS,
	DOWN
}

enum CellType {
	LOCKED,
	OPEN
}

func direction_to_vector(direction: Direction) -> Vector2i:
	match(direction):
		Direction.ACROSS:
			return Vector2i.RIGHT
		Direction.DOWN:
			return Vector2i.DOWN
	return Vector2i.ZERO

func get_other_direction(direction: Direction) -> Direction:
	match(direction):
		Direction.ACROSS:
			return Direction.DOWN
		Direction.DOWN:
			return Direction.ACROSS
	return Direction.ACROSS
