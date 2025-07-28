class_name Inhabitant
extends CharacterBody2D
## class for all moving characters in the game
##
## Owns the properties of the inhabitant, the signal handlers from the states,
## and the communication with the board. Checks for interactions with props and
## other inhabitants

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var state_machine: StateMachine = $state_machine
@onready var spark_loop: AnimatedSprite2D = $spark_loop

@export var moves_horizontally: bool = true
@export var moves_vertically: bool = true

var logical_board: LogicalBoard = null

@export var hits_waypoints: bool = false:
	get:
		return hits_waypoints
var can_escape: bool = false
var can_bump_die: bool = false
@export var can_bump_kill: bool = false
@export var can_zap_kill: bool = false

# everything about the position of the inhabitant
var cell_coords: Vector2i = Vector2i.ZERO
var swipe_direction: SwipeState.Dir = SwipeState.Dir.NONE:
	get:
		return swipe_direction
var lerp_value: float = 0

var touching_prop: Prop = null

var max_speed: float = 15
var inhabitant_accel: float = 15

# advance_vector is added to the inhabitant's cell coordinates while moving
var advance_vector: Vector2i = Vector2i.ZERO:
	get:
		return advance_vector

# When someone dies from a bump, put the killer here and the After state will find them
var bump_killer: Inhabitant = null

# When someone dies from a zap, put the killer here and the After state will find them
var zap_killer: Inhabitant = null


func provision(logical:LogicalBoard, coords: Vector2i, maxspeed: float, accel: float) -> void:
	logical_board = logical
	cell_coords = coords
	max_speed = maxspeed
	inhabitant_accel = accel
	

func _ready() -> void:
	swipe_direction = SwipeState.Dir.NONE
	state_machine.init(self, animation_player)

	# determine whether this inhabitant can win/lose
	for state:State in state_machine.get_children():
		if state is EscapeState:
			can_escape = true
		elif state is BumpDeathState:
			can_bump_die = true


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


func _on_animation_player_animation_finished(anim_name: String) -> void:
	state_machine.process_animation_finished(anim_name)


func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	state_machine.process_input(event)


func swipe_triggered(direction: SwipeState.Dir) -> void:
	if swipe_direction != SwipeState.Dir.NONE:
		return
	# No longer touching anything the inhabitant might be sitting on
	touching_prop = null

	swipe_direction = direction
	match direction:
		SwipeState.Dir.LEFT:
			advance_vector = Vector2i.LEFT
			print(get_name(), ": LEFT!")
		SwipeState.Dir.RIGHT:
			advance_vector = Vector2i.RIGHT
			print(get_name(), ": RIGHT!")
		SwipeState.Dir.UP:
			advance_vector = Vector2i.UP
			print(get_name(), ": UP!")
		SwipeState.Dir.DOWN:
			advance_vector = Vector2i.DOWN
			print(get_name(), ": DOWN!")
	#Exit the idle or ambient state
	if state_machine.current_state is IdleState:
		state_machine.current_state._on_began_move()
	elif state_machine.current_state is AmbientState:
		state_machine.current_state._on_began_move()


func advance() -> void:
	logical_board.vacate_cell(self)
	cell_coords += advance_vector
	logical_board.enter_cell(self)


func end_turn() -> void:
	swipe_direction = SwipeState.Dir.NONE
	advance_vector = Vector2i.ZERO
	if state_machine.current_state is AfterState:
		state_machine.current_state.ended_turn()


func bumped_by_inhabitant(bumper: Inhabitant) -> void:
	if can_bump_die and bumper.can_bump_kill:
		# The inhabitant may have already finished their turn. Make sure they're back on the
		# list of active inhabitants
		logical_board.inhabitant_started_turn(self)
		bump_killer = bumper
		return
	if can_bump_kill and bumper.can_bump_die:
		# The bumper may have already finished their turn. Make sure they're back on the
		# list of active inhabitants
		logical_board.inhabitant_started_turn(bumper)
		bumper.bump_killer = self
		return
	# in the case of a collision with a bomb, both parties are zapped unless they are both bombs
	if can_zap_kill and !bumper.can_zap_kill:
		if zap_killer == null:
			print(get_name(), ": ZAP! I KILLED ", bumper.get_name(), " when it bumped me.")
			logical_board.inhabitant_started_turn(bumper)
			zap_killer = self
			bumper.zap_killer = self
		return
	if bumper.can_zap_kill and !can_zap_kill:
		if bumper.zap_killer == null:
			print(get_name(), ": ZAP! ", bumper.get_name(), " KILLED ME WHEN I bumped it!!!!!")
			logical_board.inhabitant_started_turn(self)
			zap_killer = bumper
			bumper.zap_killer = self
		return
	#print(get_name(), ": I got bumped by ", bumper.get_name())
	pass


func touched_prop(prop: Prop) -> void:
	touching_prop = prop
	#print(get_name(), " contact with ", prop.get_name())
	# Check for an exit and whether we're a ball
	if prop is GoalProp:
		if can_escape:
			if state_machine.current_state is MoveState:
				var move:MoveState = state_machine.current_state
				move.escaped()
				pass
			else:
				print("Error! Hit the exit in a state other than MoveState!")
				return
	

func _on_finished_escape() -> void:
	logical_board.inhabitant_escaped(self)


func _on_finished_dying() -> void:
	logical_board.inhabitant_died(self)


func _on_got_zapped() -> void:
	if spark_loop != null:
		spark_loop.visible = true
		spark_loop.play()


func _on_started_turn() -> void:
	logical_board.inhabitant_started_turn(self)
	pass # Replace with function body.


func _on_finished_turn() -> void:
	logical_board.inhabitant_finished_turn(self)
