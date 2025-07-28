class_name IdleState
extends OneAnimationState
## Inhabitant state while waiting for player input
##
## Waits a random amount of time, then plays an ambient animation
## can also respond to being clicked on by switching to the ambient state

# idle timing
@export_range(0,100) var idle_min: int = 5
@export_range(0,100) var idle_max: int = 15
@export var is_pokeable: bool = false

# States to transition to
var ambient_state: AmbientState
var pre_move_state: BeforeState
var idle_timer: Timer = Timer.new()
var do_ambient: bool = false
var is_moving: bool = false


func _ready() -> void:
	# prior_condition is the 'end move' from the last move
	# One-time setup to add a child object that's a countdown timer to trigger ambient animations
	idle_timer.timeout.connect(ambient_time)
	idle_timer.one_shot = true
	add_child(idle_timer)


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	pre_move_state = state_machine.find_state("BeforeState")
	ambient_state = state_machine.find_state("AmbientState")
	

func enter() -> void:
	super()
	is_moving = false
	do_ambient = false
	if idle_min > 0:
		var wait_sec: int = idle_min + randi_range(0, idle_max - idle_min)
		idle_timer.start(wait_sec)
	

func process_input(event: InputEvent) -> State:
	if is_pokeable:
		if event is InputEventMouseButton:
			if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
				return ambient_state

	return super(event)


func process_frame(delta: float) -> State:
	# if the inhabitant is now busy, then there was a swipe
	if is_moving and pre_move_state != null:
		return pre_move_state

	if do_ambient:
		return ambient_state

	return super(delta)


func ambient_time() -> void:
	do_ambient = true


func _on_began_move() -> void:
	is_moving = true
