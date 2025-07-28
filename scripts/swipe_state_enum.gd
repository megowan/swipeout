class_name SwipeState
extends Object
## Common Enumerations


enum Dir {
	UP,
	DOWN,
	LEFT,
	RIGHT,
	NONE
}

# An inhabitant in the "Before Move" state wants to move from its current cell in a certain direction.
# The logical board will check the immediate path and report back one of these states.
enum PathStatus {
	# The inhabitant will immediately bump into a wall.
	WALL,

	# There is no wall, but the next cell has another inhabitant that has not yet finished moving
	WAIT_INHABITANT,
	
	# There is no wall, and there's an inhabitent in the next cell that has finished moving and will collide.
	BUMP_INHABITANT,
	
	# There is no floor, or there is a pit, or the inhabitant left the map
	FALL_DEATH,
	
	# There is no wall, and there is no inhabitant
	CLEAR
}
