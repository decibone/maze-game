extends Area2D

signal goal_reached

func _ready():
	# Connect the body_entered signal to our function
	body_entered.connect(_on_body_entered)
	
	print("Goal created! Touch it to win!")

func _on_body_entered(body):
	# Check if it's the player
	if body.name == "Player" or body.has_method("_physics_process"):
		print("GOAL REACHED!")
		emit_signal("goal_reached")
