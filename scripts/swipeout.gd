class_name SwipeoutGame
extends Node2D
## Main game class. Does nothing except initialize the main state machine and hand it ready and process

@onready var game_state: GameStateMachine = $GameState


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_state.init(self)


func _process(delta: float) -> void:
	game_state.process_frame(delta)
