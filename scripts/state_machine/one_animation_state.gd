class_name OneAnimationState
extends State
## A subclass of the inhabitant base state
##
## Adds the extra bit of intelligence to play a single animation upon entering this state

@export var anim: String


func enter() -> void:
	super()
	animation_player.play(anim)
