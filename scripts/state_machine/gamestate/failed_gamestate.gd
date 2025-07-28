class_name FailedGameState
extends GameState
## Global game state
##
## Game enters this state when the player has lost a level (ball is lost)
## The main point is to play a 'failure' noise and force the player to
## trigger a restart or board change.

signal failed_board

@export var load_map_state: LoadMapGameState = null
@onready var audio_failed: AudioStreamPlayer2D = $audio_failed

var is_load_board_event: bool = false


func enter() -> void:
	super()
	failed_board.emit()
	#print("HARPS! HARPS!")
	audio_failed.play()
	is_load_board_event = false


func process_frame(_delta: float) -> GameState:
	if is_load_board_event:
		return load_map_state
	return null


func _on_started_board_transition() -> void:
	is_load_board_event = true
