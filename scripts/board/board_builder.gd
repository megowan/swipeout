class_name BoardBuilder
extends Node
## Helper class for caching all scene resources needed to make a board
##
## Given the raw board data, instantiates a tileset scene and logical board
## then populates both with tiles, walls, inhabitants and props, and attaches
## it as a child to the board_controller

var board_controller: BoardController = null

# LogicalBoard template
var logical_board_resource: PackedScene = preload("res://scenes/logical_board.tscn")

# Theme!
var theme_circles: PackedScene = preload("res://scenes/themes/theme_circles.tscn")
var theme_dapper: PackedScene = preload("res://scenes/themes/theme_dapper.tscn")
var theme_dark: PackedScene = preload("res://scenes/themes/theme_dark.tscn")
var theme_default: PackedScene = preload("res://scenes/themes/theme_default.tscn")
var theme_flakey: PackedScene = preload("res://scenes/themes/theme_flakey.tscn")
var theme_plank: PackedScene = preload("res://scenes/themes/theme_plank.tscn")
var theme_square: PackedScene = preload("res://scenes/themes/theme_square.tscn")

# Placed objects
var ball_resource: PackedScene = preload("res://scenes/inhabitants/ball.tscn")
var neutral_resource: PackedScene = preload("res://scenes/inhabitants/neutral.tscn")
var enemy_resource: PackedScene = preload("res://scenes/inhabitants/enemy.tscn")
var rock_resource: PackedScene = preload("res://scenes/inhabitants/rock.tscn")
var bomb_resource: PackedScene = preload("res://scenes/inhabitants/bomb.tscn")
var hroller_resource: PackedScene = preload("res://scenes/inhabitants/hroller.tscn")
var vroller_resource: PackedScene = preload("res://scenes/inhabitants/vroller.tscn")
var hroller_enemy_resource: PackedScene = preload("res://scenes/inhabitants/hroller_enemy.tscn")
var vroller_enemy_resource: PackedScene = preload("res://scenes/inhabitants/vroller_enemy.tscn")

# Props
var gum_resource: PackedScene = preload("res://scenes/props/gum_prop.tscn")
var vat_resource: PackedScene = preload("res://scenes/props/vat_prop.tscn")
var pit_resource: PackedScene = preload("res://scenes/props/pit_prop.tscn")
var goal_resource: PackedScene = preload("res://scenes/props/goal_prop.tscn")
var waypoint_resource: PackedScene = preload("res://scenes/props/waypoint_prop.tscn")


# Instantiate a board from a preloaded boardview resource
# The board tuple has a data piece, a logical piece, and a view piece
func instantiate_board_tuple(board_model: BoardModel) -> BoardTuple:
	var newboard: BoardTuple = BoardTuple.new()
	newboard.raw_data = board_model

	# instantiate the theme scene
	var theme:String = newboard.raw_data.theme
	var instance: Node
	match theme:
		"circles":
			instance = theme_circles.instantiate()
		"dapper":
			instance = theme_dapper.instantiate()
		"dark":
			instance = theme_dark.instantiate()
		"flakey":
			instance = theme_flakey.instantiate()
		"plank":
			instance = theme_plank.instantiate()
		"square":
			instance = theme_square.instantiate()
		_:
			instance = theme_default.instantiate()
	newboard.set_visual(instance)

	newboard.logical = logical_board_resource.instantiate()
	newboard.logical.controller = board_controller

	board_controller.add_child(newboard.visual)

	return newboard


func build_board(board_model: BoardModel) -> BoardTuple:
	if board_model == null:
		print("build_board(): Error, no board to build")
		return
	var board: BoardTuple = instantiate_board_tuple(board_model)

	# Start by finding the size of the board
	var layout: Array[String] = board_model.layout
	var height: int = (layout.size() - 1) / 2
	var longest_row: int = 0
	for line: String in layout:
		longest_row = maxi(longest_row, line.length())
	var width: int = (longest_row - 1) / 2

	board.set_size(Vector2i(width, height))

	var is_odd_row:bool = true
	var is_odd_column:bool = true
	var cell_x: int = 0
	var cell_y: int = 0

	for line: String in layout:
		cell_x = 0
		if is_odd_row:
			is_odd_column = true
			for c: String in line:
				if c == '-':
					board.place_hwall(Vector2i(cell_x, cell_y))
				is_odd_column = !is_odd_column
				if is_odd_column:
					cell_x += 1
		else:
			is_odd_column = true
			for c: String in line:
				if is_odd_column: # check for vertical wall
					# numbers instead of '|' mean disappearing walls
					if c == '|':
						board.place_vwall(Vector2i(cell_x, cell_y))
				else: # check for floor '.'
					if c == ' ':
						pass
					elif c == 'O':
						# a pit is both a floor tile and a prop
						board.place_pit(pit_resource, Vector2i(cell_x, cell_y))
					elif c == '.':
						board.place_floor(Vector2i(cell_x, cell_y))
					else:
						board.place_floor(Vector2i(cell_x, cell_y))
						match c:
							'@':
								board.place_inhabitant(ball_resource, Vector2i(cell_x, cell_y))
							'*':
								board.place_prop(goal_resource, Vector2i(cell_x, cell_y))
							'g':
								board.place_prop(gum_resource, Vector2i(cell_x, cell_y))
							'%':
								board.place_prop(waypoint_resource, Vector2i(cell_x, cell_y))
							'n':
								board.place_inhabitant(neutral_resource, Vector2i(cell_x, cell_y))
							'e':
								board.place_inhabitant(enemy_resource, Vector2i(cell_x, cell_y))
							'u':
								board.place_prop(vat_resource, Vector2i(cell_x, cell_y))
							'^':
								board.place_inhabitant(rock_resource, Vector2i(cell_x, cell_y))
							'b':
								board.place_inhabitant(bomb_resource, Vector2i(cell_x, cell_y))
							'H':
								board.place_inhabitant(hroller_enemy_resource, Vector2i(cell_x, cell_y))
							'V':
								board.place_inhabitant(vroller_enemy_resource, Vector2i(cell_x, cell_y))
							'h':
								board.place_inhabitant(hroller_resource, Vector2i(cell_x, cell_y))
							'v':
								board.place_inhabitant(vroller_resource, Vector2i(cell_x, cell_y))
				is_odd_column = !is_odd_column
				if is_odd_column:
					cell_x += 1
		is_odd_row = !is_odd_row
		if is_odd_row:
			cell_y += 1
	board.build_image()
	return board
