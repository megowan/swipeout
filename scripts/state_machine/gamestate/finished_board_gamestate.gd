class_name FinishedBoardGameState
extends GameState
## Global game state
##
## Enters this state when a player successfully completes a board

signal advanced_to_next_board

@export var load_map_state: LoadMapGameState = null


func process_frame(_delta: float) -> GameState:
		return load_map_state


func exit() -> void:
	super()
	advanced_to_next_board.emit()
