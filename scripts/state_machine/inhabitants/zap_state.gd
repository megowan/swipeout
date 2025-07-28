class_name ZapState
extends OneAnimationState
## Inhabitant state
##
## An inhabitant enters this state when it has come into contact with the
## bomb (or is the bomb and comg into contact with a non-bomb) and is playing
## a 'zap' animation. It stays in this state until the animation is complete,
## then transitions to 'DeadState'

signal got_zapped
signal finished_dying

var dead_state: DeadState = null
var zap_done: bool = false


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	dead_state = state_machine.find_state("DeadState")


func enter() -> void:
	super()
	got_zapped.emit()
	zap_done = false


func process_frame(delta: float) -> State:
	if zap_done:
		finished_dying.emit()
		return dead_state
	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	zap_done = true
