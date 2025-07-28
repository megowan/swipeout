import xml.etree.ElementTree as ET
import json

tree = ET.parse('maps_pack1.xml')

# get root element 
root = tree.getroot() 

boards = []
print("Board count: ", len(root))

for xml_board in root:
	tileset = 'default'
	rows = []
	columns = []
	floors = []
	layout = []
	objects = []
	ceilings = []

	name = xml_board.attrib['name']

	for item in xml_board:
		if item.tag == 'tileset':
			tileset = item.text
		elif item.tag == 'row':
			rows.append(item.text)
		elif item.tag == 'column':
			columns.append(item.text)
		elif item.tag == 'floor':
			floors.append(item.text)
		elif item.tag == 'obj':
			objects.append(item)
		elif item.tag == 'ceiling':
			ceilings.append(item)

	if len(ceilings) > 0:
		name = ">< " + name + "><"
	print("** Map name: ", name)

	# Putting a note here to Future Me.
	# The count of rows and columns are each greater than the width of the board by ONE. That is because:
	#   Every cell has two vertical walls (and horizontal walls)
	#   But they share a common wall with the adjoining cell
	#   So if there are three cells in a row, there are four vertical walls
	# To get the width of the board, in cells, it's the number of columns of vertical walls minus one
	# And the height is the number of rows of horizontal walls minus one.

	width = len(columns) - 1
	# print("Width based on column count: ", width)

	height = len(rows) - 1
	# print("Height based on row count: ", height)

	expanded_width = (width * 2) + 1
	# print("Expanded width ", expanded_width)
	expanded_height = (height * 2) + 1
	# print("Expanded height ", expanded_height)
	matrix = [[' ' for i in range(expanded_width)] for j in range(expanded_height)]
	# print("Layout:", matrix)

	# default to having a floor. If a floor was specified, then it is to allow gaps or unusual shapes
	for y in range(height):
		for x in range(width):
			# print("Coordinate: ", x, " ", y)
			# print("Big Coordinate: ", x*2+1, " ", y*2+1)
			matrix[(y*2)+1][(x*2)+1] = '.'

	# look for gaps in the floor
	if len(floors) > 0:
		for y in range(len(floors)):
			row = floors[y]
			# print(row)
			for x in range(len(row)):
				c = row[x]
				if c == '0':
					matrix[(y*2)+1][(x*2)+1] = ' '
			# print("Row ", (y*2)+1)
			# print(matrix[(y*2)+1])

	# horizontal walls
	for i in range(len(rows)):
		y = i * 2
		row = rows[i]
		for j in range(len(row)):
			x = j * 2 + 1
			c = row[j]
			if c != '0':
				matrix[y][x-1] = '+'
				matrix[y][x] = '-'
				matrix[y][x+1] = '+'

	# vertical walls
	for i in range(len(columns)):
		x = i * 2
		column = columns[i]
		for j in range(len(column)):
			y = j * 2 + 1
			c = column[j]
			if c != '0':
				matrix[y-1][x] = '+'
				matrix[y][x] = '|'
				matrix[y+1][x] = '+'

	# add in the objects
	type_map = {
		'slyder': '@',
		'goal': '*',
		'pit': 'O',
		'gum': 'g',
		'neutral': 'n',
		'vat': 'u',
		'enemy': 'e',
		'sparky': 'b',
		'reginald': '^',
		'vroller': 'v',
		'vrollerenemy': 'V',
		'hroller': 'h',
		'hrollerenemy': 'H',
		'key_red': '1',
		'key_blue': '2',
		'key_yellow': '3',
		'key_green': '4',
		'key_purple': '5'
	}
	for obj in objects:
		obj_type = obj.attrib['type']
		if obj_type in type_map:
			x = int(obj.attrib['x'])
			y = int(obj.attrib['y'])
			c = type_map[obj_type]
			matrix[(y*2)+1][(x*2)+1] = c
		else:
			print("Unknown board object type ", obj_type)

	# now to build the layout strings from the matrix
	# print(matrix)
	for row in range(len(matrix)):
		# print("ROW ", row)
		# print(matrix[row])
		layout.append("".join(matrix[row]))
  

	swipeout_board = {
		"mapname" : name,
		"tileset" : tileset,
		"layout" : layout
	}
	boards.append(swipeout_board)

boardpack = {
	"boardpack" : "maps_pack1",
	"boards": boards
}

# Serialize it and write it
json_object = json.dumps(boardpack, indent=2)
 
# Writing to sample.json
with open("sample.json", "w") as outfile:
    outfile.write(json_object)
