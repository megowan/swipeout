class_name BoardTuple
extends Node
## Class to unify the model, view and controller for the game board as a single object
##
## as far as most of the game is concerned, the BoardTuple is the board. Inside, the tuple makes
## the distinctions about which version of the board needs what.

signal board_transitioned_in

var raw_data: BoardModel = null # may not need this
var logical: LogicalBoard = null
var visual: BoardView = null


func position_inhabitants() -> void:
	visual.position_inhabitants(logical.inhabitants)


func set_size(size: Vector2i) -> void:
	logical.set_size(size)	
	visual.board_size = size


func set_visual(theme: BoardView) -> void:
	visual = theme
	visual.finished_transition_in.connect(_on_finished_transition_in)
	visual.finished_transition_out.connect(_on_finished_transition_out)


func place_floor(coords: Vector2i) -> void:
	visual.place_floor(coords)
	logical.place_floor(coords)


func place_pit(resource: PackedScene, coords: Vector2i) -> void:
	var instance: Node = resource.instantiate()
	var prop: Prop = instance
	prop.provision(logical, coords)
	visual.place_pit(coords)
	# no visual because it's in the tileset, but heck, I'll position it anyhow
	visual.position_element(instance, coords)
	# the last funny thing about pits is that the are an ABSENCE of floor, so no logical presence


func place_inhabitant(resource: PackedScene, coords: Vector2i) -> void:
	var instance: Node = resource.instantiate()
	var inhabitant: Inhabitant = instance
	inhabitant.provision(logical, coords, visual.max_speed, visual.acceleration)
	visual.position_element(inhabitant, inhabitant.cell_coords)

	logical.register_new_inhabitant(inhabitant)
	logical.enter_cell(inhabitant)


func place_prop(resource: PackedScene, coords: Vector2i) -> void:
	var instance: Node = resource.instantiate()
	var prop: Prop = instance
	prop.provision(logical, coords)
	visual.position_element(instance, coords)


func place_vwall(coords: Vector2i) -> void:
	visual.place_vwall(coords)
	logical.place_vwall(coords)


func place_hwall(coords: Vector2i) -> void:
	visual.place_hwall(coords)
	logical.place_hwall(coords)


func build_image() -> void:
	visual.build_image()


func transition_in(dir: SwipeState.Dir, do_transition: bool) -> void:
	visual.transition_in(dir, do_transition)


func transition_out(dir: SwipeState.Dir, do_transition: bool) -> void:
	visual.transition_out(dir, do_transition)


func _on_finished_transition_in() -> void:
	print("*** BoardTuple: _on_finished_transition_in()")
	board_transitioned_in.emit()


func _on_finished_transition_out() -> void:
	visual.get_parent().remove_child(visual)
	self.queue_free()


# Call this when it's time to start playing
func begin() -> void:
	logical.begin()


func swipe_triggered(direction: SwipeState.Dir) -> void:
	logical.swipe_triggered(direction)
