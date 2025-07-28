class_name Initializing
extends GameState
## Global game state
##
## First state that the game is in, when configuration, assets and boards are preloaded
## Once done, triggers the loading of the first board

signal started_the_game

@export var board_collection: BoardCollection = null
@export var board_controller: BoardController = null
@export var load_map_state: LoadMapGameState = null
@export var profile_handler: ProfileHandler = null

@onready var popup_menu: HeadsUpDisplay = $"../../UI Layer/Popup"


func enter() -> void:
	super()
	profile_handler.load_profile()
	popup_menu.ingest_profile()


func exit() -> void:
	super()
	if board_controller != null:
		board_controller.lets_begin()
		started_the_game.emit()


func process_frame(_delta: float) -> GameState:
	if board_collection != null and board_collection.collection_ready:
		return load_map_state

	return null
