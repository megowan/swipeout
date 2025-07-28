class_name MoveState
extends State
## Most important inhabitant state
##
## This tragically complex state is for when the inhabitant is in motion, or about to be in motion.
## It looks ahead, accelerates, advances, checks for collisions of any kind, and transitions to
## the correct state if something happened.

@export var anim_left: String
@export var anim_right: String
@export var anim_up: String
@export var anim_down: String

var bump_state: BumpState
var bumpdeath_state: BumpDeathState
var stuck_state: StuckState
var pit_state: PitState
var vat_state: VatState
var escape_state: EscapeState
var zap_state: ZapState

var move_speed:float = 0

var is_bump_wall: bool = false
var is_bump_inhabitant: bool = false
var is_moving: bool = false
var is_fall_death: bool = false
var is_vat_death: bool = false
var is_zap_death: bool = false
var is_bump_death: bool = false
var is_wait_inhabitant: bool = false

# Only used by ball
var is_escaped: bool = false

var move_parameter: String


func populate_state_changes(state_machine: StateMachine) -> void:
	super(state_machine)
	bump_state = state_machine.find_state("BumpState")
	stuck_state = state_machine.find_state("StuckState")
	pit_state = state_machine.find_state("PitState")
	vat_state = state_machine.find_state("VatState")
	bumpdeath_state = state_machine.find_state("BumpDeathState")
	zap_state = state_machine.find_state("ZapState")
	escape_state = state_machine.find_state("EscapeState")


func enter() -> void:
	super()
	move_speed = 0
	parent.lerp_value = 0

	handle_new_cell()
	# cue animation
	if is_moving == true:
		match parent.swipe_direction:
			SwipeState.Dir.LEFT:
				animation_player.play(anim_left)
			SwipeState.Dir.RIGHT:
				animation_player.play(anim_right)
			SwipeState.Dir.UP:
				animation_player.play(anim_up)
			SwipeState.Dir.DOWN:
				animation_player.play(anim_down)


func handle_new_cell() -> void:
	#print(get_parent(), " handle_new_cell ", parent.cell_coords)
	if is_escaped:
		return
	is_bump_wall = false
	is_bump_inhabitant = false
	is_moving = false
	is_fall_death = false
	is_vat_death = false
	is_wait_inhabitant = false
	is_zap_death = false
	is_bump_death = false
	
	var path_status: SwipeState.PathStatus = parent.logical_board.check_move(parent)	
	match path_status:
		# If it's a pit or off the map, then move to the falling death state
		SwipeState.PathStatus.FALL_DEATH:
			is_fall_death = true
			parent.lerp_value = 0
		# if it's a wall, then prepare to bump
		SwipeState.PathStatus.WALL:
			is_bump_wall = true
			parent.lerp_value = 0
		# if it's an inhabitant, go to bump or BumpDeath
		SwipeState.PathStatus.BUMP_INHABITANT:
			# The exceptions to a bump is if the inhabitant is currently falling into a vat
			# or sticking to gum
			var prop: Prop = parent.touching_prop
			if prop != null:
				if prop is VatProp or prop is GumProp:
					parent.lerp_value = 0
					return
			parent.logical_board.register_bump(parent)
			parent.lerp_value = 0
			if parent.zap_killer != null:
				is_zap_death = true
			elif parent.bump_killer != null:
				is_bump_death = true
			else:
				is_bump_inhabitant = true
				
		SwipeState.PathStatus.CLEAR:
			is_moving = true
		# Inhabitant caught up with someone still in motion
		SwipeState.PathStatus.WAIT_INHABITANT:
			is_wait_inhabitant = true
			parent.lerp_value = 0
			move_speed = 0


func process_frame(delta: float) -> State:
	# Waiting on the inhabitant ahead of this one to move? Just spend this frame checking.
	if is_wait_inhabitant:
		handle_new_cell()
		return null
		
	if is_escaped:
		return escape_state
	elif is_bump_wall:
		return bump_state
	elif is_bump_inhabitant:
		return bump_state
	elif is_fall_death:
		return pit_state
	elif is_zap_death:
		return zap_state
	elif is_bump_death:
		return bumpdeath_state

	# Handle movement
	if move_speed < parent.max_speed:
		move_speed += (parent.inhabitant_accel * delta)
	parent.lerp_value += move_speed * delta
	if parent.lerp_value > 1.0:
		# entered a new cell. Do some processing
		parent.lerp_value -= 1.0
		print(parent.get_name()," advancing to next cell")
		parent.advance()
		handle_new_cell()
		# immediately after entering a cell, check for a prop touch
		var prop: Prop = parent.touching_prop
		if prop != null:
			if prop is VatProp:
				return vat_state
			elif prop is GumProp:
				return stuck_state
			elif prop is PitProp:
				return pit_state
			elif prop is GoalProp and parent.can_escape:
				return escape_state
			pass
	return super(delta)


func escaped() -> void:
	parent.lerp_value = 0
	is_escaped = true
