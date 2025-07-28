class_name LogicalBoard
extends Node
## Logical model of the board
##
## Handles all the logic of what happens in the cells of the board
## Contains the logical representation of the game board, used for determining
## how props and inhabitants can behave

@export var board_size: Vector2i = Vector2i.ZERO

var controller: BoardController = null
var num_waypoints: int = 0
var inhabitants: Array[Inhabitant] = []
var props: Array[Prop] = []
var board_cells: Array[Array] = []


func set_size(size: Vector2i) -> void:
	board_size = size
	board_cells = []

	for i in range(size.y + 1):
		board_cells.append([])
		for j in range(size.x + 1):
			board_cells[i].append(BoardCell.new())


func place_floor(coords: Vector2i) -> void:
	if coords.x < 0 or coords.x >= board_size.x:
		return
	if coords.y < 0 or coords.y >= board_size.y:
		return
	board_cells[coords.y][coords.x].has_floor = true


# vwall coordinates are based on the top-left corner, so the vwall is the left wall
# Be sure to add the 'right' wall to the cell to the left as well.
func place_vwall(coords: Vector2i) -> void:
	if coords.x < 0 or coords.x > board_size.x:
		return
	if coords.y < 0 or coords.y > board_size.y:
		return
	board_cells[coords.y][coords.x].wall_left = true
	if coords.x > 0:
		board_cells[coords.y][coords.x-1].wall_right = true


# hwall coordinates are based on the top-left corner, so the hwall is the top wall
# Be sure to add the 'bottom' wall to the cell above as well.	
func place_hwall(coords: Vector2i) -> void:
	if coords.x < 0 or coords.x > board_size.x:
		return
	if coords.y < 0 or coords.y > board_size.y:
		return
	board_cells[coords.y][coords.x].wall_up = true
	if coords.y > 0:
		board_cells[coords.y-1][coords.x].wall_down = true


func get_inhabitant(coords: Vector2i) -> Inhabitant:
	if coords.x < 0 or coords.x >= board_size.x:
		return null
	if coords.y < 0 or coords.y >= board_size.y:
		return null
	return board_cells[coords.y][coords.x].inhabitant


func vacate_cell(old_inhabitant: Inhabitant) -> void:
	var coords: Vector2i = old_inhabitant.cell_coords
	if coords.x < 0 or coords.x >= board_size.x:
		return
	if coords.y < 0 or coords.y >= board_size.y:
		return
	var cell: BoardCell = board_cells[coords.y][coords.x]
	cell.inhabitant = null
	if cell.prop != null:
		cell.prop.left_by(old_inhabitant)


func register_new_inhabitant(new_inhabitant: Inhabitant) -> void:
	inhabitants.append(new_inhabitant)
	

func inhabitant_escaped(escapee: Inhabitant) -> void:
	vacate_cell(escapee)
	if !inhabitants.has(escapee):
		print("Error: escapee was not on the inhabitant list!")
		return
	#print(escapee.get_name(), " has escaped.")
	inhabitants.erase(escapee)
	if moving_inhabitants.has(escapee):
		moving_inhabitants.erase(escapee)
		print(escapee.get_name(), " Removed from BUSY, count is ", moving_inhabitants.size())
	else:
		print(escapee.get_name(), " not on the list, ignoring!")
	escapee.queue_free()
	var count: int = 0
	for inhabitant in inhabitants:
		if inhabitant.can_escape:
			count += 1
	print("Remaining escapists: ", count)
	if count == 0:
		#print("Time to advance to the next board.")
		controller.board_completed()
	else:
		if moving_inhabitants.is_empty():
			print("ending turn")
			end_turn()


func inhabitant_died(deader: Inhabitant) -> void:
	vacate_cell(deader)
	if !inhabitants.has(deader):
		print("Error: deader was not on the inhabitant list!")
		return
	print(deader.get_name(), " has died.")
	inhabitants.erase(deader)
	inhabitant_finished_turn(deader)
	if deader.can_escape:
		print("-= The PROTAGONIST is DEAD =-")
		controller.board_ball_died()
	deader.queue_free()


func enter_cell(new_inhabitant: Inhabitant) -> void:
	var x: int = new_inhabitant.cell_coords.x
	var y: int = new_inhabitant.cell_coords.y
	
	# If the inhabitant went off the edge of the map, there's no cell to add them to
	if x < 0 or y < 0 or x > board_size.x or y > board_size.y:
		return

	var cell: BoardCell = board_cells[y][x]
	cell.inhabitant = new_inhabitant
	if cell.prop != null:
		cell.prop.touched_by(new_inhabitant)


func place_prop(new_prop: Prop) -> void:
	#if coords.x < 0 or coords.x >= board_size.x:
		#return
	#if coords.y < 0 or coords.y >= board_size.y:
		#return
	props.append(new_prop)
	board_cells[new_prop.cell_coords.y][new_prop.cell_coords.x].prop = new_prop
	if new_prop is WaypointProp:
		num_waypoints += 1


func get_prop(coords: Vector2i) -> Prop:
	if coords.x < 0 or coords.x >= board_size.x:
		return null
	if coords.y < 0 or coords.y >= board_size.y:
		return null
	return board_cells[coords.y][coords.x].prop


func remove_prop(coords: Vector2i) -> void:
	if coords.x < 0 or coords.x >= board_size.x:
		return
	if coords.y < 0 or coords.y >= board_size.y:
		return
	board_cells[coords.y][coords.x].prop = null


func deactivate_waypoint(_waypoint: WaypointProp) -> void:
	#print("Deactivating waypoint")
	num_waypoints -= 1
	if num_waypoints == 0:
		activate_goals()


func register_bump(inhabitant: Inhabitant) -> void:
	var coords: Vector2i = inhabitant.cell_coords

	# Skipping validation because this is only ever called after check_move, which validated
	match inhabitant.swipe_direction:
		SwipeState.Dir.UP:
			coords.y -= 1
		SwipeState.Dir.DOWN:
			coords.y += 1
		SwipeState.Dir.LEFT:
			coords.x -= 1
		SwipeState.Dir.RIGHT:
			coords.x += 1
		SwipeState.Dir.NONE:
			pass
	var cell: BoardCell = board_cells[coords.y][coords.x]
	var target: Inhabitant = cell.inhabitant
	if target != null:
		target.bumped_by_inhabitant(inhabitant)


func check_move(inhabitant: Inhabitant) -> SwipeState.PathStatus:
	var x: int = inhabitant.cell_coords.x
	var y: int = inhabitant.cell_coords.y

	# Check whether the inhabitant is currently off the edge of the world
	if x < 0 or x > board_size.x or y < 0 or y > board_size.y:
		return SwipeState.PathStatus.FALL_DEATH
		
	var cell: BoardCell = board_cells[y][x]
	
	# Check if there's a hole in the ground
	if cell.has_floor == false:
		return SwipeState.PathStatus.FALL_DEATH

	# Check if there is a wall to bump into in that direction
	match inhabitant.swipe_direction:
		SwipeState.Dir.UP:
			if cell.wall_up:
				return SwipeState.PathStatus.WALL
		SwipeState.Dir.DOWN:
			if cell.wall_down:
				return SwipeState.PathStatus.WALL
		SwipeState.Dir.LEFT:
			if cell.wall_left:
				return SwipeState.PathStatus.WALL
		SwipeState.Dir.RIGHT:
			if cell.wall_right:
				return SwipeState.PathStatus.WALL

	# There was no wall. Next see whether there is a cell
	match inhabitant.swipe_direction:
		SwipeState.Dir.UP:
			y -= 1
		SwipeState.Dir.DOWN:
			y += 1
		SwipeState.Dir.LEFT:
			x -= 1
		SwipeState.Dir.RIGHT:
			x += 1
		SwipeState.Dir.NONE:
			pass
	# If going off the top or left and there's no wall, then that's a clear path (to DOOM)
	# Because bottom walls are created partially as top walls of lower cells, and right walls
	# are created as left walls of right-er cells, then there will always be an empty (floorless)
	# cell along the right and bottom edge, so we don't need to check that case.
	if x < 0 or y < 0:
		return SwipeState.PathStatus.CLEAR

	# If there's no floor in the cell, then that's clear (DOOM, again)
	var nextcell: BoardCell = board_cells[y][x]
	if nextcell.has_floor == false:
		return SwipeState.PathStatus.CLEAR

	# If there's a pit, then that's clear
	if nextcell.prop != null:
		if nextcell.prop is PitProp:
			return SwipeState.PathStatus.CLEAR

	# If the cell is unoccupied, then that's clear
	var ahead: Inhabitant = nextcell.inhabitant
	if ahead == null:
		return SwipeState.PathStatus.CLEAR
		
	# There's an inhabitant in the cell. If their state is AFTER then they're done moving
	var ahead_state_machine: StateMachine = ahead.state_machine
	var ahead_state: State = ahead_state_machine.current_state
	print(inhabitant.get_name(), ": ", ahead.get_name(), " ahead state is ", ahead_state.get_name())
	# Cannot assume that the character ahead has stopped moving on a bump, because there could
	# be a zap-death. That means that in a moment, two inhabitants are going to disappear
	if ahead_state is AfterState or ahead_state is StuckState:
		print(inhabitant.get_name(), ": Bumping ", ahead.get_name() ," who stopped moving")
		return SwipeState.PathStatus.BUMP_INHABITANT
	
	return SwipeState.PathStatus.WAIT_INHABITANT


func swipe_triggered(direction: SwipeState.Dir) -> void:
	for inhabitant:Inhabitant in inhabitants:
		inhabitant.swipe_triggered(direction)
	controller.moving_began.emit()


func end_turn() -> void:
	for inhabitant:Inhabitant in inhabitants:
		inhabitant.end_turn()
	controller.moving_finished.emit()

var moving_inhabitants: Dictionary = {}


func inhabitant_started_turn(inhabitant: Inhabitant) -> void:
	if moving_inhabitants.has(inhabitant):
		print("Double entry, ignoring")
		return
	moving_inhabitants[inhabitant] = true
	print(inhabitant.get_name(), " Added to BUSY, count is ", moving_inhabitants.size())


# Called after an inhabitant has finished moving and didn't come to harm, or after they have
# died (bump, zap, vat, pit) and finished their death animation
func inhabitant_finished_turn(inhabitant: Inhabitant) -> void:
	if moving_inhabitants.has(inhabitant):
		moving_inhabitants.erase(inhabitant)
		print(inhabitant.get_name(), " Removed from BUSY, count is ", moving_inhabitants.size())
	else:
		print(inhabitant.get_name(), " not on the list, ignoring!")
		return
	if moving_inhabitants.is_empty():
		print("ending turn")
		end_turn()


func begin() -> void:
	# if there are any waypoints, tell every goal to deactivate
	if num_waypoints > 0:
		for prop in props:
			if prop is GoalProp:
				var goal:GoalProp = prop
				goal.deactivate_goal()
	pass


func activate_goals() -> void:
	for prop in props:
		if prop is GoalProp:
			var goal:GoalProp = prop
			goal.activate_goal()


class BoardCell:
	var has_floor: bool
	var wall_up: bool
	var wall_down: bool
	var wall_left: bool
	var wall_right: bool
	var inhabitant: Inhabitant
	var prop: Prop
