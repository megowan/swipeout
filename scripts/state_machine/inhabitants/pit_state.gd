class_name PitState
extends OneAnimationState
## Inhabitant state
##
## Inhabitant enters this state to play an animation and sound when it has either
## entered a pit or fallen off the board. When the animation is done, the inhabitant
## transitions to the 'Dead State'

signal finished_dying

var dead_state: DeadState = null
var pit_done: bool = false


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	dead_state = state_machine.find_state("DeadState")


func enter() -> void:
	super()
	pit_done = false
	# There's not always a pit. Could just be a hole in the floor. 	


func process_frame(delta: float) -> State:
	if pit_done:
		finished_dying.emit()
		return dead_state
	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	pit_done = true
