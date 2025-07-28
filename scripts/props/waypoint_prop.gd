class_name WaypointProp
extends Prop
## Prop type that only the ball can touch
##
## On levels with waypoints, the goal is not available until a ball has touched every
## waypoint.

@export var enabled: bool = true
@onready var audio_waypoint: AudioStreamPlayer2D = $audio_waypoint


func _ready() -> void:
	enabled = true
	set_frame(1)


func touched_by(inhabitant: Inhabitant) -> void:
	if enabled:
		# Only do something if this is the ball.
		if inhabitant.hits_waypoints:
			inhabitant.touched_prop(self)
			enabled = false
			audio_waypoint.play()
			set_frame(0)
			logical_board.deactivate_waypoint(self)
