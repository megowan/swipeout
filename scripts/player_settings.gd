class_name PlayerSettings
extends Resource
## Struct to hold the player's configuration

# https://docs.godotengine.org/en/stable/tutorials/scripting/resources.html
# https://www.reddit.com/r/godot/comments/p6szd9/saving_settings_input_graphics_sound_etc/


@export var level: int  = 0
@export var current_level: int = 0
@export var full_screen: bool = false
@export var audio_on: bool = false
@export var music_on: bool = false


func _init() -> void:
	current_level = 0
	level = 2
	full_screen = false
	audio_on = false
	music_on = false

