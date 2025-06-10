extends CharacterBody2D

var speed = 300.0
var cell_size = 20
var can_move = true


func _physics_process(delta):
	if not can_move:
		return
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
