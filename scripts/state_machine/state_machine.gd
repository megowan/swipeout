class_name StateMachine
extends Node
## Inhabitant state machine
##
## State machine possessed by every inhabitant, plus a little extra administrative work to help
## setup the state machine upon initialization
@export var starting_state: State

var current_state: State


func init(parent: CharacterBody2D, animation_player: AnimationPlayer) -> void:
	# Initialize the state machine by giving each child state a reference to the
	# parent object it belongs to and enter the default starting_state
	for child in get_children():
		child.parent = parent
		child.animation_player = animation_player
		child.populate_state_changes(self)
	
	# Initialize to the default state
	change_state(starting_state)


func find_state(state_type: String) -> State:
	var result: Array[Node] = find_children("*", state_type)
	if result.size() > 0:
		return result[0]
	return null


# Change to the new state by first calling any exit logic on the current state
func change_state(new_state: State) -> void:
	if current_state:
		current_state.exit()
	
	current_state = new_state
	current_state.enter()


# Pass through functions for the Player to call,
# handling state changes as needed.
func process_physics(delta: float) -> void:
	var new_state: State = current_state.process_physics(delta)
	if new_state:
		change_state(new_state)


func process_input(event: InputEvent) -> void:
	var new_state: State = current_state.process_input(event)
	if new_state:
		change_state(new_state)


func process_frame(delta: float) -> void:
	var new_state: State = current_state.process_frame(delta)
	if new_state:
		change_state(new_state)


func process_animation_finished(anim_name: String) -> void:
	current_state.process_animation_finished(anim_name)
