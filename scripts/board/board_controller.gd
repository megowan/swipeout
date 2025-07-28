class_name BoardController
extends Node2D
## BoardController
##
## Owns the shuffling in and out of game boards. Works with Board Tuples and the Board Builder

# Signals for use by BoardController
signal moving_began
signal moving_finished
signal board_complete
signal board_failed

signal started_board_transition
signal finished_board_transition
signal player_started_board
signal controller_changed_board

@export var board_collection:BoardCollection = null

@onready var player_profile_handler: ProfileHandler = $"../PlayerProfileHandler"
@onready var audio_finishing_level: AudioStreamPlayer2D = $audio_finishing_level

const TRANSITION_BACKGROUND = true
const NO_TRANSITION_BACKGROUND = false

var current_board_index: int = 0
var current_theme: String = ""
var board_view: BoardView = null
var board_builder: BoardBuilder
var incoming_board:BoardTuple = null
var current_board:BoardTuple = null


func _ready() -> void:
	board_builder = BoardBuilder.new()
	board_builder.board_controller = self
	

func _process(_delta: float) -> void:
	if current_board != null:
		current_board.position_inhabitants()


func transition_to_board(board_index: int, from: SwipeState.Dir, to: SwipeState.Dir) -> void:
	var board_model:BoardModel = board_collection.get_board_by_index(board_index)
	var transition:bool = NO_TRANSITION_BACKGROUND
	if board_index != current_board_index or current_board == null:
		transition = TRANSITION_BACKGROUND

	# handle any transition out if there's a current_board
	if current_board != null:
		current_board.transition_out(to, transition)
		current_board = null

	incoming_board = board_builder.build_board(board_model)
	print("+++ connecting _on_board_transitioned_in to incoming board")
	# Argh. Must connect this signal before calling transition_in(), because the method itself
	# may do an instant transition and emit the signal
	incoming_board.board_transitioned_in.connect(_on_board_transitioned_in)
	incoming_board.transition_in(from, transition)
	update_popup()
	started_board_transition.emit()

func _on_board_transitioned_in() -> void:
	current_board = incoming_board
	update_popup()
	current_board.begin()
	incoming_board = null
	print("+_+_+ Finished board transition")
	finished_board_transition.emit()

func lets_begin() -> void:
	print("Let's begin.")
	current_board_index = player_profile_handler.CurrentLevel
	transition_to_board(current_board_index, SwipeState.Dir.RIGHT, SwipeState.Dir.LEFT)


func _on_requested_next_board() -> void:
	if current_board == null:
		return
	var next_board_index: int = current_board_index + 1
	# When a player has completed the entire game, next and previous allow wraparound access
	if next_board_index >=  player_profile_handler.Level:
		return
	if next_board_index >= board_collection.size:
		next_board_index = 0

	transition_to_board(next_board_index, SwipeState.Dir.RIGHT, SwipeState.Dir.LEFT)
	current_board_index = next_board_index
	player_started_board.emit(current_board_index)
	#player_profile_handler.CurrentLevel = current_board_index


func _on_requested_previous_board() -> void:
	if current_board == null:
		return
	var previous_board_index: int = current_board_index - 1
	if current_board_index == 0:
		if player_profile_handler.Level == board_collection.size:
			previous_board_index = board_collection.size - 1
		else:
			return

	transition_to_board(previous_board_index, SwipeState.Dir.LEFT, SwipeState.Dir.RIGHT)
	current_board_index = previous_board_index
	player_started_board.emit(current_board_index)
	#player_profile_handler.CurrentLevel = current_board_index	


func _on_requested_restart_board() -> void:
	if current_board == null:
		return
	#Fetch a new copy of the current board and do an instant transition
	transition_to_board(current_board_index, SwipeState.Dir.LEFT, SwipeState.Dir.RIGHT)


func update_popup() -> void:
	var board_name: String = ""
	if current_board != null:
		board_name = "%d. %s" % [current_board_index + 1, current_board.raw_data.name]
	controller_changed_board.emit(board_name, current_board_index > 0, current_board_index < player_profile_handler.Level)


func _on_swipe_triggered(direction: SwipeState.Dir) -> void:
	if current_board != null:
		current_board.swipe_triggered(direction)


func board_completed() -> void:
	# Signal that it's time to move from the 'Moving' GameState to the 'FinishedBoard' state
	board_complete.emit()
	audio_finishing_level.play()

	if current_board_index + 1 >=  player_profile_handler.Level:
		player_profile_handler.Level += 1
	_on_requested_next_board()


func board_ball_died() -> void:
	print("board_controller.board_ball_died()")
	board_failed.emit()
