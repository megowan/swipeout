class_name BumpDeathState
extends OneAnimationState
## Inhabitant state
##
## An inhabitant that can be killed by bumping into--or being bumped into by--an enemy
## enters this state. It will play the bumpdeath sound and animation. When it completes the
## animation, transition to the 'Dead State'

signal finished_dying

var dead_state: DeadState = null
var bumpdeath_done: bool = false


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	dead_state = state_machine.find_state("DeadState")


func enter() -> void:
	super()
	bumpdeath_done = false


func process_frame(delta: float) -> State:
	if bumpdeath_done:
		finished_dying.emit()
		return dead_state

	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	bumpdeath_done = true
