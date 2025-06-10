extends CharacterBody2D

var speed = 200.0
var cell_size = 20

func _ready():
	# Start at a grid-aligned position
	position = Vector2(30, 30)

func _physics_process(delta):
	# Simple movement with arrow keys
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed("ui_right"):
		direction.x += 1
	if Input.is_action_pressed("ui_left"):
		direction.x -= 1
	if Input.is_action_pressed("ui_down"):
		direction.y += 1
	if Input.is_action_pressed("ui_up"):
		direction.y -= 1
	
	velocity = direction * speed
	move_and_slide()
