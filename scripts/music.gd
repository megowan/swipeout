extends Node

var tracks: Array[AudioStreamPlayer2D]
var current_track:int = 0

func _ready() -> void:
	for child in get_children():
		if child is AudioStreamPlayer2D:
			tracks.append(child)

func start_music() -> void:
	tracks[current_track].play()

func next_music() -> void:
	tracks[current_track].stop()
	current_track = (current_track + 1) % tracks.size()
	tracks[current_track].play()

func _on_started_the_game() -> void:
	start_music()

func _on_advanced_to_next_board() -> void:
	next_music()

