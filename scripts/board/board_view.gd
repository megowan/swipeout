class_name BoardView
extends Node
## Owns the rendering aspect of the game board
##
## On the MVC paradigm, owns the "View" aspect of the game board. Owns the tileset, tilemap,
## and logic behind creating visuals based on the human-readable description of the board.
## Owns the placement of objects based upon the dimensions, positioning, transitions, etc.

signal finished_transition_in
signal finished_transition_out

const LAYER_SHADOWS = 0
const LAYER_FLOOR = 1

const SOURCE_SHADOWS = 0
const SOURCE_FLOORS = 2

@export var max_speed: float = 15
@export var acceleration: float = 15

@export var transition_duration: float = 0.5

@onready var tile_map: TileMap = $TileMap
@onready var background: Sprite2D = $Background

var cell_size: Vector2i

var walltile_dict: Dictionary = {}
class CellWalls:
	var up: bool
	var down: bool
	var left: bool
	var right: bool

var board_cells: Array = []

var board_size: Vector2i = Vector2i.ZERO:
	get:
		return board_size
	set(new_size): 
		board_size = new_size
		# (re)build the 2d array
		board_cells = []
		for i in range(board_size.y + 1):
			board_cells.append([])
			for j in range(board_size.x + 1):
				board_cells[i].append(CellWalls.new())
		resize()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	build_wall_dictionary()
	get_tree().get_root().size_changed.connect(resize)
	cell_size = tile_map.tile_set.tile_size
	pass # Replace with function body.


func build_wall_dictionary() -> void:
	# Scan the tileset texture tileset atlas custom data to build a map
	# showing which tile to use for which corners where walls meet
	walltile_dict = {}

	for source_id in tile_map.tile_set.get_source_count():
		if not tile_map.tile_set.get_source(source_id) is TileSetAtlasSource:
			continue
		var source : TileSetAtlasSource = tile_map.tile_set.get_source(source_id)
		for tile_index in source.get_tiles_count():
			var coords := source.get_tile_id(tile_index)
			var tile_data := source.get_tile_data(coords, 0)
			var wall_data: Variant = tile_data.get_custom_data('wall_data')
			if wall_data.length() > 0:
				walltile_dict[wall_data] = coords


func resize() -> void:
	var screen_size: Vector2i = tile_map.get_viewport_rect().size
	var center: Vector2 = screen_size / 2.0

	# Compute how much to stretch the background as the greater of the horizontal and vertical stretch
	var bg_width: float = background.texture.get_width()
	var bg_height: float = background.texture.get_height()
	var h_scale: float = screen_size.x / bg_width
	var v_scale: float = screen_size.y / bg_height

	# background sprite is a float scalar
	var bg_scale: float = maxf(h_scale, v_scale)

	# Scale the tilemap as a rounded integer
	var tile_scale: float = floorf(bg_scale)

	# center and scale the background
	background.position = center
	background.scale = Vector2(bg_scale, bg_scale)

	# center the map
	var delta: Vector2 = board_size * tile_map.tile_set.tile_size * tile_scale
	tile_map.position = center - (delta/2.0)
	tile_map.scale = Vector2(tile_scale, tile_scale)


# add as a child and then position it
func place_floor(coords: Vector2i) -> void:
	tile_map.set_cell(LAYER_SHADOWS, coords, SOURCE_SHADOWS, Vector2i(0,0), 0)
	tile_map.set_cell(LAYER_FLOOR, coords, SOURCE_FLOORS , Vector2i(0,0), 0)


# add as a child and then position it
func place_pit(coords: Vector2i) -> void:
	tile_map.set_cell(LAYER_SHADOWS, coords, SOURCE_SHADOWS, Vector2i(1,0), 0)
	tile_map.set_cell(LAYER_FLOOR, coords, SOURCE_FLOORS , Vector2i(1,0), 0)


# add as a child and then position it
func position_element(element: Node2D, coords: Vector2i) -> void:
	tile_map.add_child(element)
	element.position = Vector2i(coords.x * tile_map.tile_set.tile_size.x, coords.y * tile_map.tile_set.tile_size.y)


func position_inhabitants(inhabitants: Array[Inhabitant]) -> void:
	for inhabitant in inhabitants:
		var coords: Vector2i = inhabitant.cell_coords
		var pos: Vector2i = Vector2i(coords.x * cell_size.x, coords.y * cell_size.y)
		var lerpvalue: float = inhabitant.lerp_value
		match inhabitant.swipe_direction:
			SwipeState.Dir.UP:
				pos.y -= (int)(lerpvalue * cell_size.y)
			SwipeState.Dir.DOWN:
				pos.y += (int)(lerpvalue * cell_size.y)
			SwipeState.Dir.LEFT:
				pos.x -= (int)(lerpvalue * cell_size.x)
			SwipeState.Dir.RIGHT:
				pos.x += (int)(lerpvalue * cell_size.x)
		inhabitant.position = pos


# Update the position of an inhabitant that moves and is already a child
func position_moving_element(element: Node2D, coords: Vector2i, lerpvalue: float, direction: SwipeState.Dir) -> void:
	var pos: Vector2i = Vector2i(coords.x * cell_size.x, coords.y * cell_size.y)
	match direction:
		SwipeState.Dir.UP:
			pos.y -= (int)(lerpvalue * cell_size.y)
		SwipeState.Dir.DOWN:
			pos.y += (int)(lerpvalue * cell_size.y)
		SwipeState.Dir.LEFT:
			pos.x -= (int)(lerpvalue * cell_size.x)
		SwipeState.Dir.RIGHT:
			pos.x += (int)(lerpvalue * cell_size.x)
	element.position = pos
	

func place_vwall(coords: Vector2i) -> void:
	# a vertical wall is specifially the left wall of a cell.
	# So for the right wall of the rightmost cell in a row, it's the left wall
	# of an empty cell
	# NodeWalls are based on the top left corner of a cell
	# So a vertical wall extends down from cell (x,y)
	# And a vertical wall extends up from cell (x,y+1)
	board_cells[coords.y][coords.x].down = true
	board_cells[coords.y+1][coords.x].up = true


func place_hwall(coords: Vector2i) -> void:
	# a horizontal wall is specifially the top wall of a cell.
	# So for the bottom wall of the bottommost cell in a row, it's the top wall
	# of an empty cell
	# NodeWalls are based on the top left corner of a cell
	# So a horizontal wall extends right from cell (x,y)
	# And a vertical wall extends left from cell (x+1,y)
	board_cells[coords.y][coords.x].right = true
	board_cells[coords.y][coords.x+1].left = true
	

func build_image() -> void:
	for row in board_size.y + 1:
		for column in board_size.x + 1:
			var dict_key: String = ""
			var boardNode: CellWalls = board_cells[row][column]
			if boardNode.up:
				dict_key += "u"
			if boardNode.down:
				dict_key += "d"
			if boardNode.left:
				dict_key += "l"
			if boardNode.right:
				dict_key += "r"
			if dict_key.length() > 0:
				var coords: Vector2i = walltile_dict[dict_key]
				tile_map.set_cell(2, Vector2i(column,row), 1, coords, 0)
		pass
	pass
	resize()


func transition_in(dir: SwipeState.Dir, do_transition: bool) -> void:
	# transition is for background. Always do the slide
	#print("Transition in")
	if do_transition:
		resize()
		var screen_size: Vector2i = tile_map.get_viewport_rect().size
		var dest: Vector2 = tile_map.position
		match dir:
			SwipeState.Dir.UP:
				tile_map.position.y -= screen_size.y
			SwipeState.Dir.DOWN:
				tile_map.position.y += screen_size.y
			SwipeState.Dir.LEFT:
				tile_map.position.x -= screen_size.x
			_: # RIGHT
				tile_map.position.x += screen_size.x
		var slide_tween: Tween = get_tree().create_tween()
		slide_tween.tween_property(tile_map, "position", dest, transition_duration)
		slide_tween.tween_callback(transition_in_complete)
		# move the background back one z-index
		background.z_index = -1
	else:
		#print("(Instant transition in)")
		finished_transition_in.emit()


func transition_in_complete() -> void:
	finished_transition_in.emit()
	background.z_index = 0


func transition_out(dir: SwipeState.Dir, do_transition: bool) -> void:
	if do_transition:
		resize()
		var screen_size: Vector2i = tile_map.get_viewport_rect().size
		var dest: Vector2 = tile_map.position
		match dir:
			SwipeState.Dir.UP:
				dest.y -= screen_size.y
			SwipeState.Dir.DOWN:
				dest.y += screen_size.y
			SwipeState.Dir.LEFT:
				dest.x -= screen_size.x
			_: # RIGHT
				dest.x += screen_size.x
		pass
		var slide_tween: Tween = get_tree().create_tween()
		slide_tween.tween_property(tile_map, "position", dest, transition_duration)
		slide_tween.tween_callback(transition_out_complete)

		var fade_tween: Tween = get_tree().create_tween()
		fade_tween.tween_property(background, "modulate:a", 0, transition_duration)
		fade_tween.tween_callback(fade_out_complete)
	else:
		finished_transition_out.emit()
		pass


func transition_out_complete() -> void:
	finished_transition_out.emit()


func fade_out_complete() -> void:
	#print("fade out complete")
	pass
