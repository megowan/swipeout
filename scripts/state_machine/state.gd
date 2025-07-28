class_name State
extends Node
## Base inhabitant state machine state

var parent: Inhabitant
var animation_player: AnimationPlayer
var sounds: Array[AudioStreamPlayer2D]


func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D:
			sounds.append(child)

# called during initialization to look up the states to transition to
func populate_state_changes(_state_machine: StateMachine) -> void:
	pass
	

func enter() -> void:
	print(parent.get_name()," >>entering<< ", get_name())
	# pick a sound randomly, if there are any attached
	if sounds.size() > 0:
		var pick_sound: AudioStreamPlayer2D = sounds[randi() % sounds.size()]
		pick_sound.play()


func exit() -> void:
	print(parent.get_name()," <<exiting>> ", get_name())


func process_input(_event: InputEvent) -> State:
	return null


func process_frame(_delta: float) -> State:
	return null


func process_physics(_delta: float) -> State:
	return null


func process_animation_finished(_anim_name: String) -> void:
	print(parent.get_name(), ", state: ", get_name(), " finished animation: ", _anim_name)
