class_name GumProp
extends Prop
## Prop type to force an inhabitant from 'moving' to 'stuck' state.
##
## Has two frames. Could someday be two animations. Works on all inhabitants
## Upon being touched, tells the inhabitant that it's stuck and plays a
## 'stuck' sound.

@onready var audio_gum_stuck: AudioStreamPlayer2D = $audio_gum_stuck


func touched_by(inhabitant: Inhabitant) -> void:
	# switch to squished frame
	inhabitant.touched_prop(self)
	audio_gum_stuck.play()
	set_frame(1)


func left_by(_inhabitant: Inhabitant) -> void:
	# switch to unsquished frame
	set_frame(0)
