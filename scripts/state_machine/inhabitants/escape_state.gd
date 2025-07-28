class_name EscapeState
extends OneAnimationState
## Inhbitant state
##
## An inhabitant that can escape enters this state when it touches a goal.
## It will play the escape sound and escape animation. When the animation is
## complete, it will emit the 'finished_escape' signal, which the board will
## capture to know to remove the inhabitant. If that was the last inhabitant
## needed to win the board, then the win condition is triggered.

signal finished_escape

var escape_done: bool = false


func enter() -> void:
	super()
	escape_done = false


func process_frame(delta: float) -> State:
	if escape_done:
		finished_escape.emit()
	return super(delta)


func process_animation_finished(anim_name: String) -> void:
	super(anim_name)
	escape_done = true
	
