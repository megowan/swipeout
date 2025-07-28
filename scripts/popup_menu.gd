class_name HeadsUpDisplay
extends Control
## UI handler for HUD overlay
##
## Integrates with display service, player settings, and board controller
## Handles all buttons for controlling the user experience

signal requested_previous_board
signal requested_next_board
signal requested_restart_board

@onready var open: Control = $Open
@onready var closed: Control = $Closed
@onready var audio_on_button: TextureButton = $Open/BackgroundTint/RightGrid/AudioOnButton
@onready var audio_off_button: TextureButton = $Open/BackgroundTint/RightGrid/AudioOffButton
@onready var music_off_button: TextureButton = $Open/BackgroundTint/RightGrid/MusicOffButton
@onready var music_on_button: TextureButton = $Open/BackgroundTint/RightGrid/MusicOnButton
@onready var larger_button: TextureButton = $Open/BackgroundTint/RightGrid/LargerButton
@onready var smaller_button: TextureButton = $Open/BackgroundTint/RightGrid/SmallerButton
@onready var previous_board_button: TextureButton = $Open/BackgroundTint/RightGrid/LeftButton
@onready var next_board_button: TextureButton = $Open/BackgroundTint/RightGrid/RightButton

@onready var player_profile: ProfileHandler = $"../../PlayerProfileHandler"

@onready var board_name_label: Label = $Footer/VBoxContainer/BoardNameLabel
@onready var footer_restart_button: TextureButton = $Footer/VBoxContainer/FooterRestartButton


func _ready() -> void:
	get_tree().get_root().size_changed.connect(on_resize)


# The viewport changed. See what the windowed/fullscreen buttons should be
func on_resize() -> void:
	#var window_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	#if window_mode == DisplayServer.WINDOW_MODE_MAXIMIZED:
		#_is_fullscreen = true
	#else: # DisplayServer.WINDOW_MODE_WINDOWED
		#_is_fullscreen = false
	pass
	

func _input(event: InputEvent) -> void:
	if Input.is_action_pressed("next_board"):
		requested_next_board.emit()
		return
	if Input.is_action_pressed("previous_board"):
		requested_previous_board.emit()
		return
	if Input.is_action_pressed("restart_board"):
		requested_restart_board.emit()
		return
	if event.is_action_pressed("popup"):
		_is_popup_visible = !_is_popup_visible
		return
	if event is InputEventKey and event.is_pressed():
		if _is_popup_visible:
			_is_popup_visible = false
	
# Configuration
	

var _is_popup_visible:bool = false:
	set(value):
		_is_popup_visible = value
		open.visible = _is_popup_visible
		closed.visible = !_is_popup_visible


var _is_audio_on:bool = true:
	set(value):
		_is_audio_on = value
		audio_on_button.visible = _is_audio_on
		audio_off_button.visible = !_is_audio_on
		player_profile.AudioOn = _is_audio_on


var _is_music_on:bool = true:
	set(value):
		_is_music_on = value
		music_on_button.visible = _is_music_on
		music_off_button.visible = !_is_music_on
		player_profile.MusicOn = _is_music_on


var _is_fullscreen:bool = false:
	set(value):
		_is_fullscreen = value
		smaller_button.visible = _is_fullscreen
		larger_button.visible = !_is_fullscreen
		player_profile.FullScreen = _is_fullscreen

# Button handlers


func _on_settings_button_pressed() -> void:
	_is_popup_visible = false


func _on_closed_settings_button_pressed() -> void:
	_is_popup_visible = true


func _on_restart_button_pressed() -> void:
	requested_restart_board.emit()


func _on_left_button_pressed() -> void:
	requested_previous_board.emit()


func _on_right_button_pressed() -> void:
	requested_next_board.emit()


func _on_audio_on_button_pressed() -> void:
	_is_audio_on = false


func _on_audio_off_button_pressed() -> void:
	_is_audio_on = true


func _on_music_on_button_pressed() -> void:
	_is_music_on = false


func _on_music_off_button_pressed() -> void:
	_is_music_on = true


func _on_larger_button_pressed() -> void:
	print("Fullscreen!")
	_is_fullscreen = true


func _on_smaller_button_pressed() -> void:
	print("Windowed!")
	_is_fullscreen = false


func _on_exit_button_pressed() -> void:
	get_tree().quit()


func ingest_profile() -> void:
	_is_fullscreen = player_profile.FullScreen
	_is_audio_on = player_profile.AudioOn
	_is_music_on = player_profile.MusicOn


func set_prev_next_arrows(enable_previous:bool, enable_next:bool) -> void:
	previous_board_button.disabled = !enable_previous
	if enable_previous:
		previous_board_button.modulate = Color(1,1,1)
	else:
		previous_board_button.modulate = Color(.5,.5,.5)

	next_board_button.disabled = !enable_next
	if enable_next:
		next_board_button.modulate = Color(1,1,1)
	else:
		next_board_button.modulate = Color(.5,.5,.5)


func set_board_name(board_name: String) -> void:
	print("Received new board name: ", board_name)
	board_name_label.text = board_name


func _on_board_failed() -> void:
	footer_restart_button.visible = true


func _on_started_board_transition() -> void:
	footer_restart_button.visible = false


func _on_controller_changed_board(board_name: String, enable_previous: bool, enable_next: bool) -> void:
	print("Received new board name: ", board_name)
	board_name_label.text = board_name
	previous_board_button.disabled = !enable_previous
	if enable_previous:
		previous_board_button.modulate = Color(1,1,1)
	else:
		previous_board_button.modulate = Color(.5,.5,.5)

	next_board_button.disabled = !enable_next
	if enable_next:
		next_board_button.modulate = Color(1,1,1)
	else:
		next_board_button.modulate = Color(.5,.5,.5)
	pass # Replace with function body.
