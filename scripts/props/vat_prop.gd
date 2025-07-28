class_name VatProp
extends Prop
## 'Trap' Prop type
##
## Prop that destroys the first inhabitant that passes over it (like quicksand) but becomes
## benign, ignoring all other inhabitants afterwards.

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var audio_vat_swallow: AudioStreamPlayer2D = $AnimatedSprite2D/audio_vat_swallow

var is_filled: bool = false


func _ready() -> void:
	is_filled = false
	animated_sprite_2d.play("vat_idle")


func touched_by(inhabitant: Inhabitant) -> void:
	if is_filled:
		#print("vat is full: ignoring touch by ", inhabitant.get_name())
		return
	#else:
		#print("vat is empty, swallowing ", inhabitant.get_name())
	is_filled = true
	inhabitant.touched_prop(self)
	animated_sprite_2d.visible = false


func swallow_inhabitant(anim_name: String) -> void:
	animated_sprite_2d.visible = true
	animated_sprite_2d.play(anim_name)
	audio_vat_swallow.play()
