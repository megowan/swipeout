class_name AfterState
extends OneAnimationState
## Inhabitant state
##
## Inhabitants enter this state when they believe that they are done with their action
## and stay here until all other inhabitants have finished moving. It's possible that
## an inhabitant can be stuck back into a non-after state if it gets bumped by something deadly.
## Other than that, it waits here for other inhabitants before returning to 'Idle' state.

signal finished_turn

@export var condition: String = "end move"

# States we can transition to from "Idle"
var idle_state: IdleState
var bumpdeath_state: BumpDeathState
var zap_state: ZapState
var is_ended_turn: bool = false
# note that an inhabitant can be finished moving, but might still die from a bump or a zap
var is_finished_moving: bool = false


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	idle_state = state_machine.find_state("IdleState")
	bumpdeath_state = state_machine.find_state("BumpDeathState")
	zap_state = state_machine.find_state("ZapState")


func enter() -> void:
	super()
	is_ended_turn = false
	is_finished_moving = false


func process_frame(delta: float) -> State:
	if parent.bump_killer != null:
		return bumpdeath_state
	if parent.zap_killer != null:
		return zap_state

	# no impending death? We're clear to say the turn is truly over
	if !is_finished_moving:
		is_finished_moving = true
		finished_turn.emit()

	if is_ended_turn:
		return idle_state

	return super(delta)


func ended_turn() -> void:
	is_ended_turn = true
