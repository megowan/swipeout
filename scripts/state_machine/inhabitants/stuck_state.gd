class_name StuckState
extends DirectionalState
## Inhabitant state entered upon stepping on gum
##
## Upon hitting hum, inhabitant transitions from 'moving' to 'stuck'. After finishing the 'stuck'
## animation, transitions to 'after'. Note that while stuck, the inhabitant can still be lethally
## bumped or zapped

# States we can transition to from "After"
var after_state: AfterState
var bumpdeath_state: BumpDeathState = null
var zap_state: ZapState = null
var stuck_done: bool = false

# TODO this state can be interrupted by bumpdeath or zapdeath

func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	after_state = state_machine.find_state("AfterState")
	bumpdeath_state = state_machine.find_state("BumpDeathState")
	zap_state = state_machine.find_state("ZapState")


func enter() -> void:
	super()
	stuck_done = false


func process_frame(delta: float) -> State:
	if parent.bump_killer != null:
		return bumpdeath_state
	if parent.zap_killer != null:
		return zap_state
	if stuck_done:
		return after_state
	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	stuck_done = true
