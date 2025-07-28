class_name PitProp
extends Prop
## Prop type for deadly fall
##
## Since the logical board controller already handles the case of "oh hey there's no
## floor here", the main purpose of the pit being aware something entered it is to
## play the 'falling' sound.

@onready var audio_pit_fall: AudioStreamPlayer2D = $audio_pit_fall


func do_your_thing() -> void:
	audio_pit_fall.play()


func touched_by(inhabitant: Inhabitant) -> void:
	inhabitant.touched_prop(self)
