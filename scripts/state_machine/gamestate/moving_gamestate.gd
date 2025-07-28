class_name MovingGameState
extends GameState
## Global game state
##
## Game stays in this state while inhabitants are in motion

@export var waiting_game_state: WaitingGameState = null
@export var failed_game_state: FailedGameState = null
@export var finished_game_state: FinishedBoardGameState = null
@export var loadmap_game_state: LoadMapGameState = null

var is_moving_finished: bool = false
var is_failed_board: bool = false
var is_finished_board: bool = false
var is_loading_board: bool = false


func enter() -> void:
	super()
	is_failed_board = false
	is_finished_board = false
	is_moving_finished = false
	is_loading_board = false


func process_frame(delta: float) -> GameState:
	if is_failed_board:
		return failed_game_state
	elif is_moving_finished:
		return waiting_game_state
	elif is_finished_board:
		return finished_game_state
	elif is_loading_board:
		return loadmap_game_state
	return super(delta)
	

func _on_moving_finished() -> void:
	is_moving_finished = true


func _on_board_failed() -> void:
	print("Gamestate moving: got the signal that the board failed")
	is_failed_board = true


func _on_board_complete() -> void:
	is_finished_board = true


# Used for changing maps mid-move
func _on_started_board_transition() -> void:
	is_loading_board = true
