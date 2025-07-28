class_name BumpState
extends DirectionalState
## Inhabitant state
##
## Entered when a moving inhabitant hits a wall or another inhabitant

var after_state: AfterState = null
var bumpdeath_state: BumpDeathState = null
var zap_state: ZapState = null
var bump_done: bool = false

# TODO this state can be interrupted by bumpdeath

func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	after_state = state_machine.find_state("AfterState")
	bumpdeath_state = state_machine.find_state("BumpDeathState")
	zap_state = state_machine.find_state("ZapState")


func enter() -> void:
	super()
	bump_done = false


func process_frame(delta: float) -> State:
	if parent.bump_killer != null:
		return bumpdeath_state
	if parent.zap_killer != null:
		return zap_state
	if bump_done:
		return after_state
	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	bump_done = true
