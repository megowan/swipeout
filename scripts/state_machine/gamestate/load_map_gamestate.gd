class_name LoadMapGameState
extends GameState
## Global game state before a board is ready to play
##
## Enters this state after initializing or whenever a map is transitioning in.

@export var waiting_game_state: WaitingGameState = null

var is_board_loaded_event:bool = false


func exit() -> void:
	super()
	is_board_loaded_event = false


func process_frame(_delta: float) -> GameState:
	if is_board_loaded_event:
		return waiting_game_state
	return null


func _on_board_controller_finished_board_transition() -> void:
	#print("on board controller finished board transition")
	is_board_loaded_event = true
