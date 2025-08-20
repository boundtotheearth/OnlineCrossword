class_name CellData
extends Resource

@export var answer: String = ""
@export var number: int = 0
@export var type: Globals.CellType = Globals.CellType.LOCKED
@export var clues: Dictionary[Globals.Direction, ClueData]
