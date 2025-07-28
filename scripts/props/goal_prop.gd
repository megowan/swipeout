class_name GoalProp
extends Prop
## Exit prop type
##
## Only used by inhabitants who can escape. If the level has waypoints, then
## the goal is inactive (translucent) until all waypoints have been touched.
## When an inhabitant that can escape passes over an active goal, the inhabitant
## is notified, and can take action.

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var audio_dingdong: AudioStreamPlayer2D = $audio_dingdong

var active: bool = true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("idle")
	active = true


func touched_by(inhabitant: Inhabitant) -> void:
	if !inhabitant.hits_waypoints:
		return
	if !active:
		return
	inhabitant.touched_prop(self)


func deactivate_goal() -> void:
	self.self_modulate.a = 0.4
	active = false


func activate_goal() -> void:
	self.self_modulate.a = 1.0
	active = true
	audio_dingdong.play()
