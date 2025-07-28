class_name GameState
extends Node
## Base class for global game states
##
## Overload these classes to implement specific states, and call super() if you want
## debug information

var parent: Node2D


func enter() -> void:
	print("++ Enter gamestate ", get_name(), " ++")


func exit() -> void:
	print("-- Exit gamestate ", get_name(), " --")


func process_input(_event: InputEvent) -> GameState:
	return null


func process_frame(_delta: float) -> GameState:
	return null
