class_name DirectionalState
extends State
## Subclass of the base state, with the context of a movement direction
##
## Subclasses the base 'State' and adds the brains to pick one of four animations to play
## based upon the movement direction

@export var anim_left: String
@export var anim_right: String
@export var anim_up: String
@export var anim_down: String


# Called when the node enters the scene tree for the first time.
func enter() -> void:
	super()
	print(parent.get_name(), ">> selecting directional animation <<")
	match parent.swipe_direction:
		SwipeState.Dir.LEFT:
			animation_player.play(anim_left)
		SwipeState.Dir.RIGHT:
			animation_player.play(anim_right)
		SwipeState.Dir.UP:
			animation_player.play(anim_up)
		SwipeState.Dir.DOWN:
			animation_player.play(anim_down)

