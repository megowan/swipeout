class_name Prop
extends Sprite2D
## Base Prop class
##
## A Prop is an object that lies on the floor of a board, which inhabitants roll over.
## Not every inhabitant interacts with every prop. When an inhabitant enters a cell
## the logical board handler notifies the prop about it, and the prop makes a
## determination about whether to do anything about it.

var logical_board: LogicalBoard = null
var cell_coords: Vector2i = Vector2i.ZERO


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func provision(board:LogicalBoard, coords: Vector2i) -> void:
	logical_board = board
	cell_coords = coords
	logical_board.place_prop(self)


func touched_by(_inhabitant: Inhabitant) -> void:
	pass


func left_by(_inhabitant: Inhabitant) -> void:
	pass
