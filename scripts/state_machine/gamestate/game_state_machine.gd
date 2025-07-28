class_name GameStateMachine
extends Node
## Global game state management
##
## Intercepts inputs and sends them only to the currently active state. Handles transitions

@export var starting_state: GameState

var current_state: GameState


func init(parent: Node2D) -> void:
	# Initialize the state machine by giving each child state a reference to the
	# parent object it belongs to and enter the default starting_state
	for child in get_children():
		child.parent = parent
	
	# Initialize to the default state
	change_state(starting_state)


# Change to the new state by first calling any exit logic on the current state
func change_state(new_state: GameState) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()


func process_input(event: InputEvent) -> void:
	var new_state: GameState = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state: GameState = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)
