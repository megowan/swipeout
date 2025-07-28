extends AnimatedSprite2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func suffix(dir: SwipeState.Dir) -> String:
	match dir:
		SwipeState.Dir.UP:
			return "_up"
		SwipeState.Dir.DOWN:
			return "_down"
		SwipeState.Dir.LEFT:
			return "_left"
		SwipeState.Dir.RIGHT:
			return "_right"
	return ""

func _ready() -> void:
	animation_player.play("sparks_idle1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass

func idle() -> void:
	animation_player.play("sparks_idle1")

func ambient() -> void:
	animation_player.play("sparks_ambient")
	
func death() -> void:
	animation_player.play("sparks_ambient")

func look(direction: SwipeState.Dir) -> void:
	animation_player.play("sparks_look" + suffix(direction))

func roll(direction: SwipeState.Dir) -> void:
	animation_player.play("sparks_move" + suffix(direction))

func bump(direction: SwipeState.Dir) -> void:
	animation_player.play("sparks_bump" + suffix(direction))

func stuck(direction: SwipeState.Dir) -> void:
	animation_player.play("sparks_bump" + suffix(direction))

func pit() -> void:
	animation_player.play("sparks_pitfall")

func vat() -> void:
	animation_player.play("sparks_vatfall")
	pass

