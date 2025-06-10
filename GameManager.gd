# GameManager.gd - Autoload singleton
extends Node

var selected_algorithm: String = "astar"

# Statistics tracking
var path_length: int = 0
var nodes_explored: int = 0
var time_taken: float = 0.0

func reset_stats():
	path_length = 0
	nodes_explored = 0
	time_taken = 0.0
