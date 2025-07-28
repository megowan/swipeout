class_name ProfileHandler
extends Node
## Class for loading and saving player settings

@export var swipeout:SwipeoutGame = null
@export var resource_path: String = "res://playersettings.tres"

var player_profile: PlayerSettings = null
var has_changed: bool = false


func _process(_delta: float) -> void:
	if has_changed:
		save_profile()

# Auto-save on any profile change
var Level: int :
	get:
		return player_profile.level
	set(value):
		player_profile.level = value
		has_changed = true

var CurrentLevel: int :
	get:
		return player_profile.current_level
	set(value):
		player_profile.current_level = value
		has_changed = true

var FullScreen: bool :
	get:
		return player_profile.full_screen
	set(value):
		player_profile.full_screen = value
		if player_profile.full_screen == true:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		if player_profile.full_screen == false:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		has_changed = true

var AudioOn: bool :
	get:
		return player_profile.audio_on
	set(value):
		player_profile.audio_on = value
		var sfx_bus_index: int = AudioServer.get_bus_index("SFX")
		AudioServer.set_bus_mute(sfx_bus_index, !player_profile.audio_on)
		has_changed = true

var MusicOn: bool :
	get:
		return player_profile.music_on
	set(value):
		player_profile.music_on = value
		var music_bus_index: int = AudioServer.get_bus_index("Music")
		AudioServer.set_bus_mute(music_bus_index, !player_profile.music_on)
		has_changed = true


func load_profile() -> void:
	player_profile = load(resource_path)
	if player_profile == null:
		print("Creating a new profile")
		player_profile = PlayerSettings.new()
	print("Max Level: ", Level, ", Current: ", CurrentLevel, " FullScreen: ", FullScreen, ", AudioOn: ", AudioOn, ", MusicOn: ", MusicOn)


func save_profile() -> void:
	print("SAVING Max Level: ", Level, ", Current: ", CurrentLevel, " FullScreen: ", FullScreen, ", AudioOn: ", AudioOn, ", MusicOn: ", MusicOn)
	ResourceSaver.save(player_profile, resource_path)
	has_changed = false


func _on_player_started_board(value: int) -> void:
	CurrentLevel = value
