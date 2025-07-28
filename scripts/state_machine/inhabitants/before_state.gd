class_name BeforeState
extends DirectionalState
## Inhabitant state
##
## When a swipe operation begins, every inhabitant starts in this state. From here, they
## check whether they have the ability to move. If they can't, then they transition to 'After'.
## If they have the ability, then they check whether the path ahead has an inhabitant that's
## still in the square and not yet done moving. If so, then we stay in this state until the
## path is clear. Then the inhabitant transitions, even if they're just going to bump into
## something, to the Move state.

# Inhabitants that are going to roll, but which have to wait for something ahead of them to clear
# enter this state until they can actually move. Things can bump into them safely until they reach
# their final resting spot, at which time all sparks and other kills happen

signal started_turn

var move_state: MoveState
var after_state: AfterState
var skip_move: bool = false


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	move_state = state_machine.find_state("MoveState")
	after_state = state_machine.find_state("AfterState")


func enter() -> void:
	super()
	started_turn.emit()
	skip_move = false
	
	# check whether this inhabitant will move
	if parent.moves_horizontally == false:
		if parent.swipe_direction == SwipeState.Dir.LEFT || parent.swipe_direction == SwipeState.Dir.RIGHT:
			skip_move = true
			return
	if parent.moves_vertically == false:
		if parent.swipe_direction == SwipeState.Dir.UP || parent.swipe_direction == SwipeState.Dir.DOWN:
			skip_move = true
			return


# Trigger the exit to this state when the path forward is unobstructed
func exit() -> void:
	super()


func process_frame(_delta: float) -> State:
	if skip_move:
		print(parent.get_name(), " SKIPPING and going to after-state")
		return after_state

	var path_status: SwipeState.PathStatus = parent.logical_board.check_move(parent)

	# Only one state--waiting for someone else to move--keeps us here.
	if path_status == SwipeState.PathStatus.WAIT_INHABITANT:
		#print(parent.get_name(), " Waiting for someone to move")
		return null

	# The MoveState will also check the status of the next cell on enter()
	# And decide to bump a wall or an inhabitant, or start a move to the next cell
	#print(parent.get_name(), " Can switch to MOVE state")
	return move_state
