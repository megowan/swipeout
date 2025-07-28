class_name WaitingGameState
extends GameState
## Global game state
##
## Waits in this state for board changes or player input

signal swipe_triggered

@export var load_map_state: LoadMapGameState = null
@export var moving_state: MovingGameState = null

var is_load_board_event: bool = false
var is_move_event: bool = false

var is_swiping: bool = false
var click_position: Vector2
var drag_vector: Vector2
var swipe_minimum_threshold: int = 50
var swipe_threshold: int = 200


func enter() -> void:
	super()
	is_load_board_event = false
	is_move_event = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		# start swiping if it's a click
		if not is_swiping and event.pressed:
			#print("Start swipe")
			is_swiping = true
			click_position = event.position
		# stop swipe if button is release
		if is_swiping and not event.pressed:
			is_swiping = false
			#print("Stop swipe")
			analyze_swipe()
	if event is InputEventMouseMotion and is_swiping:
		drag_vector = event.position - click_position
		if drag_vector.length() > swipe_threshold:
			#print("Stop long swipe")
			is_swiping = false
			analyze_swipe()

	# Only accept swipe commands during the wait state
	if Input.is_action_pressed("swipe_left"):
		swipe_triggered.emit(SwipeState.Dir.LEFT)
		return
	if Input.is_action_pressed("swipe_right"):
		swipe_triggered.emit(SwipeState.Dir.RIGHT)
		return
	if Input.is_action_pressed("swipe_up"):
		swipe_triggered.emit(SwipeState.Dir.UP)
		return
	if Input.is_action_pressed("swipe_down"):
		swipe_triggered.emit(SwipeState.Dir.DOWN)
		return


func analyze_swipe() -> void:
	if drag_vector.length() < swipe_minimum_threshold:
		return
	#print("Length: ", drag_vector.length(), ", angle: ", rad_to_deg(drag_vector.angle()))
	var horizontal_span: int = abs(drag_vector.x)
	var vertical_span: int = abs(drag_vector.y)
	if horizontal_span > vertical_span * 4 or vertical_span > horizontal_span * 4:
		# the travel along one axis is at least 4x what it is in the other
		var theta: float = rad_to_deg(drag_vector.angle())
		if theta < 45 and theta > -45:
			swipe_triggered.emit(SwipeState.Dir.RIGHT)
		elif theta > 45 and theta < 135:
			swipe_triggered.emit(SwipeState.Dir.DOWN)
		elif theta < -45 and theta > -135:
			swipe_triggered.emit(SwipeState.Dir.UP)
		elif theta > 135 or theta < -135:
			swipe_triggered.emit(SwipeState.Dir.LEFT)
		pass
	pass


func process_frame(_delta: float) -> GameState:
	if is_load_board_event:
		return load_map_state
	if is_move_event:
		return moving_state
	return null


func _on_moving_began() -> void:
	is_move_event = true


func _on_started_board_transition() -> void:
	is_load_board_event = true
