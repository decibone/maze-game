extends CharacterBody2D

@export var speed: float = 200.0
@export var tile_size: int = 16

var grid: Array = []
var grid_width: int
var grid_height: int
var start_pos: Vector2i
var goal_pos: Vector2i
var current_path: Array = []
var path_index: int = 0
var moving: bool = false
var algorithm_name: String = ""

# Algorithm-specific variables
var explored_nodes: Array = []
var open_set: Array = []
var closed_set: Array = []

func _ready():
	# Get the algorithm from GameManager
	algorithm_name = GameManager.selected_algorithm
	
	# Initialize the grid based on your maze
	setup_grid()
	
	# Start pathfinding
	GameManager.reset_stats()
	var _start_time = Time.get_time_dict_from_system()
	var start_usec = Time.get_unix_time_from_system() * 1000000  # Get microseconds
	match algorithm_name:
		"astar":
			current_path = find_path_astar()
		"backtrack":
			current_path = find_path_backtrack()
		"greedy":
			current_path = find_path_greedy()
	
	var end_usec = Time.get_unix_time_from_system() * 1000000  # Get microseconds
	GameManager.time_taken = (end_usec - start_usec) / 1000.0  # Convert to milliseconds
	GameManager.path_length = current_path.size()
	GameManager.nodes_explored = explored_nodes.size()
	
	print("Algorithm: ", algorithm_name)
	print("Path length: ", GameManager.path_length)
	print("Nodes explored: ", GameManager.nodes_explored)
	print("Time taken: ", GameManager.time_taken, "ms")

func setup_grid():
	# You'll need to adapt this to your maze structure
	# This assumes you have a way to detect walls/obstacles
	var tilemap = get_parent().get_node("TileMap") # Adjust path as needed
	print("TileMap found: ", tilemap != null)
	
	# Get grid dimensions
	var used_rect = tilemap.get_used_rect()
	grid_width = used_rect.size.x
	grid_height = used_rect.size.y
	
	# Initialize grid
	grid = []
	for y in range(grid_height):
		var row = []
		for x in range(grid_width):
			var tile_pos = Vector2i(x, y)
			var tile_id = tilemap.get_cell_source_id(0, tile_pos)
			# Assuming tile_id -1 means empty space, adjust as needed
			row.append(tile_id == 1)
		grid.append(row)
	
	# Set start and goal positions (you'll need to adapt this)
	start_pos = Vector2i(50,50)
	# You'll need to get the goal position from your maze
	goal_pos = Vector2i(1205, 565) # Example

func _physics_process(delta):
	if current_path.size() > 0 and path_index < current_path.size():
		move_along_path(delta)

func move_along_path(_delta):
	if path_index >= current_path.size():
		return
	
	var target_pos = Vector2(current_path[path_index].x * tile_size, current_path[path_index].y * tile_size)
	var direction = (target_pos - global_position).normalized()
	
	velocity = direction * speed
	move_and_slide()
	
	# Check if we've reached the current target
	if global_position.distance_to(target_pos) < 5:
		path_index += 1
		if path_index >= current_path.size():
			print("Goal reached!")

# A* Algorithm
func find_path_astar() -> Array:
	var start = Node2D.new()
	start.position = Vector2(start_pos)
	start.set_meta("grid_pos", start_pos)
	start.set_meta("g_cost", 0)
	start.set_meta("h_cost", heuristic(start_pos, goal_pos))
	start.set_meta("f_cost", start.get_meta("h_cost"))
	start.set_meta("parent", null)
	
	open_set = [start]
	closed_set = []
	explored_nodes = []
	
	while open_set.size() > 0:
		# Find node with lowest f_cost
		var current = open_set[0]
		for i in range(1, open_set.size()):
			if open_set[i].get_meta("f_cost") < current.get_meta("f_cost"):
				current = open_set[i]
		
		open_set.erase(current)
		closed_set.append(current)
		explored_nodes.append(current.get_meta("grid_pos"))
		
		# Check if we reached the goal
		if current.get_meta("grid_pos") == goal_pos:
			return reconstruct_path(current)
		
		# Check neighbors
		var neighbors = get_neighbors(current.get_meta("grid_pos"))
		for neighbor_pos in neighbors:
			if is_in_closed_set(neighbor_pos):
				continue
			
			var g_cost = current.get_meta("g_cost") + 1
			var existing_node = get_node_from_open_set(neighbor_pos)
			
			if existing_node == null:
				var neighbor = Node2D.new()
				neighbor.set_meta("grid_pos", neighbor_pos)
				neighbor.set_meta("g_cost", g_cost)
				neighbor.set_meta("h_cost", heuristic(neighbor_pos, goal_pos))
				neighbor.set_meta("f_cost", g_cost + neighbor.get_meta("h_cost"))
				neighbor.set_meta("parent", current)
				open_set.append(neighbor)
			elif g_cost < existing_node.get_meta("g_cost"):
				existing_node.set_meta("g_cost", g_cost)
				existing_node.set_meta("f_cost", g_cost + existing_node.get_meta("h_cost"))
				existing_node.set_meta("parent", current)
	
	return []

# Backtracking Algorithm (Depth-First Search)
func find_path_backtrack() -> Array:
	var visited = {}
	var path = []
	explored_nodes = []
	
	if backtrack_recursive(start_pos, visited, path):
		return path
	return []

func backtrack_recursive(pos: Vector2i, visited: Dictionary, path: Array) -> bool:
	if pos == goal_pos:
		path.append(pos)
		return true
	
	visited[pos] = true
	explored_nodes.append(pos)
	path.append(pos)
	
	var neighbors = get_neighbors(pos)
	for neighbor in neighbors:
		if not visited.has(neighbor):
			if backtrack_recursive(neighbor, visited, path):
				return true
	
	path.pop_back()
	return false

# Greedy Best-First Search
func find_path_greedy() -> Array:
	var start = Node2D.new()
	start.set_meta("grid_pos", start_pos)
	start.set_meta("h_cost", heuristic(start_pos, goal_pos))
	start.set_meta("parent", null)
	
	open_set = [start]
	closed_set = []
	explored_nodes = []
	
	while open_set.size() > 0:
		# Find node with lowest h_cost (greedy)
		var current = open_set[0]
		for i in range(1, open_set.size()):
			if open_set[i].get_meta("h_cost") < current.get_meta("h_cost"):
				current = open_set[i]
		
		open_set.erase(current)
		closed_set.append(current)
		explored_nodes.append(current.get_meta("grid_pos"))
		
		if current.get_meta("grid_pos") == goal_pos:
			return reconstruct_path(current)
		
		var neighbors = get_neighbors(current.get_meta("grid_pos"))
		for neighbor_pos in neighbors:
			if is_in_closed_set(neighbor_pos) or get_node_from_open_set(neighbor_pos) != null:
				continue
			
			var neighbor = Node2D.new()
			neighbor.set_meta("grid_pos", neighbor_pos)
			neighbor.set_meta("h_cost", heuristic(neighbor_pos, goal_pos))
			neighbor.set_meta("parent", current)
			open_set.append(neighbor)
	
	return []

# Helper functions
func get_neighbors(pos: Vector2i) -> Array:
	var neighbors = []
	var directions = [Vector2i(0, 1), Vector2i(1, 0), Vector2i(0, -1), Vector2i(-1, 0)]
	
	for dir in directions:
		var new_pos = pos + dir
		if is_valid_position(new_pos):
			neighbors.append(new_pos)
	
	return neighbors

func is_valid_position(pos: Vector2i) -> bool:
	return pos.x >= 0 and pos.x < grid_width and pos.y >= 0 and pos.y < grid_height and grid[pos.y][pos.x]

func heuristic(a: Vector2i, b: Vector2i) -> float:
	return abs(a.x - b.x) + abs(a.y - b.y)  # Manhattan distance

func reconstruct_path(node) -> Array:
	var path = []
	var current = node
	
	while current != null:
		path.push_front(current.get_meta("grid_pos"))
		current = current.get_meta("parent")
	
	return path

func is_in_closed_set(pos: Vector2i) -> bool:
	for node in closed_set:
		if node.get_meta("grid_pos") == pos:
			return true
	return false

func get_node_from_open_set(pos: Vector2i):
	for node in open_set:
		if node.get_meta("grid_pos") == pos:
			return node
	return null

# Removed the calculate_time_diff function as it's no longer needed
