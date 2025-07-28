class_name VatState
extends OneAnimationState
## Inhabitant state
##
## Inhabitant Enters this state upon stumbling over an open vat. It does a bit of
## sleight-of-hand, as the vat itself will vanish while the inhabitant plays an
## animation of itself falling into the vat. Once the animation is done, however,
## the inhabitant is removed from the scene. At that point, the inhabitant passes
## a looping 'vat idle' animation to the vat to play for the rest of the board's
## life.

signal finished_dying

@export var vat_idle_anim: String = ""

var dead_state: DeadState = null
var vat_done: bool = false
var vat_prop: VatProp = null


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	dead_state = state_machine.find_state("DeadState")


func enter() -> void:
	super()
	# note which vat prop the character is on
	vat_prop = parent.touching_prop
	vat_done = false


func exit() -> void:
	super()
	vat_prop.swallow_inhabitant(vat_idle_anim)


func process_frame(delta: float) -> State:
	if vat_done:
		#parent._on_finished_dying()
		finished_dying.emit()
		return dead_state
	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	vat_done = true
