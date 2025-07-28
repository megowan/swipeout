class_name AmbientState
extends State
## Inhabitant state for playing a single, random animation and a sound effect

@export var animations: Array[String]

# States we can transition to from "Idle"
var idle_state: IdleState
var pre_move_state: BeforeState
var ambient_done: bool = false
var is_moving: bool = false

func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	idle_state = state_machine.find_state("IdleState")
	pre_move_state = state_machine.find_state("BeforeState")


# By default, prepare to just go back to the idle state.
# But if there's at least one animation, stay in this state until the animation is complete
func enter() -> void:
	super()
	is_moving = false
	ambient_done = true
	if animations.size() > 0:
		ambient_done = false
		var pick_animation: int = randi() % animations.size()
		animation_player.play(animations[pick_animation])
		

func process_frame(delta: float) -> State:
	if is_moving and pre_move_state != null:
		return pre_move_state

	if ambient_done:
		return idle_state
	return super(delta)


func process_animation_finished(_anim_name: String) -> void:
	super(_anim_name)
	ambient_done = true


func _on_began_move() -> void:
	is_moving = true
