# MainMenu.gd
extends Control

# Assuming your maze scene is called "Maze.tscn"
const MAZE_SCENE = "res://level.tscn"

func _ready():
	# Connect buttons to their respective functions
	$VBoxContainer/Astar.pressed.connect(_on_astar_pressed)
	$VBoxContainer/Backtracking.pressed.connect(_on_backtrack_pressed)
	$VBoxContainer/Greedy.pressed.connect(_on_greedy_pressed)

func _on_astar_pressed():
	GameManager.selected_algorithm = "astar"
	get_tree().change_scene_to_file(MAZE_SCENE)

func _on_backtrack_pressed():
	GameManager.selected_algorithm = "backtrack"
	get_tree().change_scene_to_file(MAZE_SCENE)

func _on_greedy_pressed():
	GameManager.selected_algorithm = "greedy"
	get_tree().change_scene_to_file(MAZE_SCENE)
