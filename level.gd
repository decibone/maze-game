extends Node2D  # or whatever your main node type is

# Timer variables
var elapsed_time: float = 0.0
var game_active: bool = true
var game_completed: bool = false

# Get references to UI elements
@onready var timer_label = $timer/timerlabel
@onready var status_label = $timer/status
@onready var goal = $goal  # Adjust path to match your goal's location
@onready var player = $Player  # Adjust path to match your player's location

func _ready():
	# Connect goal signal
	goal.goal_reached.connect(_on_goal_reached)
	
	print("Game started! Timer is running...")
	print("Use arrow keys to move and reach the green goal!")

func _process(delta):
	if game_active and not game_completed:
		# Add delta time to our elapsed time
		elapsed_time += delta
		timer_label.text = "Time: %.2f" % elapsed_time

func _on_goal_reached():
	if game_completed:
		return
	
	game_completed = true
	game_active = false
	
	# Update UI
	timer_label.text = "Final Time: %.2f seconds" % elapsed_time
	status_label.text = "GOAL REACHED! Well done!"
	status_label.modulate = Color.GREEN
	
	# Stop player movement
	if player.has_method("stop_movement"):
		player.stop_movement()
	
	print("GAME COMPLETED!")
	print("Final time: %.2f seconds" % elapsed_time)
	
	# Optional: Restart message
	await get_tree().create_timer(3.0).timeout
	print("Press Enter to restart")

func _input(event):
	if event.is_action_pressed("ui_accept") and game_completed:
		restart_game()

func restart_game():
	# Reset timer
	elapsed_time = 0.0
	game_active = true
	game_completed = false
	
	# Reset UI
	status_label.text = "Reach the goal!"
	status_label.modulate = Color.WHITE
	
	# Reset goal
	goal.modulate = Color.WHITE
	goal.scale = Vector2.ONE
	
	# Reset player
	if player.has_method("reset_position"):
		player.reset_position()
	else:
		player.position = Vector2(30, 30)  # Adjust to your start position
	
	print("Game restarted!")
