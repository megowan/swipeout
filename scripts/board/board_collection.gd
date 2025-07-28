class_name BoardCollection
extends Node
## Collection of BoardModel
##
## Ingests and maintains the collection of all gameboards in their raw, human-readable state



var collection_ready:bool = false
var board_pack_list_file: String = "res://boards/board_pack_order.json"
# In the shipped product, paths will be from "user://" but while in development I am pulling from
# "res://" so that DropBox persists level data
var path: String = "res://data.json"
var boards_path: String = "res://boards/"
var board_pack_list: Array
var board_pack_dictionary: Dictionary

# This is the final list assembled using the board pack list as an index into the various files
var board_collection: Array[BoardModel] = []

var size: int :
	get:
		return board_collection.size()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fetch_pack_list()
	
	var list: PackedStringArray = DirAccess.get_files_at(boards_path)
	for file in list:
		print("Found file '%s'" % file)
		if (file.to_lower() != "board_pack_order.json"):
			if (file.to_lower().ends_with(".json")):
				parse_pack(file)

	assemble_board_collection()
	collection_ready = true


func assemble_board_collection() -> void:
	#print("assemble_board_collection()")
	for pack: String in board_pack_list:
		if board_pack_dictionary.has(pack):
			board_collection.append_array(board_pack_dictionary.get(pack))
	#print("Final collection size is: %d" % board_collection.size())
	#for item:BoardModel in board_collection:
		#print("--%s" % item.name)
	board_pack_dictionary.clear()
	board_pack_list.clear()
		

func fetch_pack_list() -> void:
	var file: FileAccess = FileAccess.open(board_pack_list_file, FileAccess.READ)
	var text: String = file.get_as_text()
	var json:JSON = JSON.new()
	var data: Variant
	
	var error: Error = json.parse(text)
	if error == OK:
		data = json.data
		board_pack_list = data['board_pack_order']
		print(board_pack_list)
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", text, " at line ", json.get_error_line())
	

func parse_pack(filename: String) -> void:
	print("Parsing file '%s'" % filename)
	var file: FileAccess = FileAccess.open(boards_path + filename, FileAccess.READ)
	var text: String = file.get_as_text()
	var json: JSON = JSON.new()
	var data: Variant
	var error: Error = json.parse(text)

	if error == OK:
		data = json.data
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", text, " at line ", json.get_error_line())
	
	if data.has("boardpack") and data.has("boards"):
		var packname:String = data['boardpack']
		if packname not in board_pack_list:
			return
		print("--valid pack '%s'" % packname)
		var boards_in_pack: Array[BoardModel] = []
		for board: Variant in data['boards']:
			#var mapname:String = board['mapname']
			#print("----found board '%s'" % mapname)
			var newboard: BoardModel = BoardModel.new()
			newboard.name = board['mapname']
			newboard.theme = board['tileset']
			#newboard.layout = []
			for line: Variant in board['layout']:
				newboard.layout.append(line)
			boards_in_pack.append(newboard)
			#print("----Ingested board %s" % newboard.name)
		print("Appending %d boards in pack '%s' to the game" % [boards_in_pack.size(), packname])
		board_pack_dictionary[packname] = boards_in_pack


func get_board_by_index(index:int) -> BoardModel:
	if (index < 0):
		print("get_board_by_index() error: index below zero")
		return null
	if board_collection.size() == 0:
		print("get_board_by_index() error: no boards loaded.")
		return null
	if (index > board_collection.size()):
		print("get_board_by_index() error: index is outside bounds of collection of boards")
		return null
	return board_collection[index]
