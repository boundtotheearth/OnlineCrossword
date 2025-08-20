class_name CrosswordData
extends Resource

@export var id: String = ""
@export var creator: String = ""
@export var title: String = ""
@export var dimentions: Vector2i = Vector2i.ZERO
@export var cells: Array[CellData] = []
@export var clues: Array[ClueData] = []
