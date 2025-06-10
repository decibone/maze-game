extends CharacterBody2D

const speed = 150
@export var player: Node = null

func _ready() -> void:
	$NavigationAgent2D.target_position = player.global_position
func _physics_process(_delta: float) -> void:
	var dir = to_local($NavigationAgent2D.get_next_path_position()).normalized()
	velocity = dir * speed
	move_and_slide()

func make_path() -> void:
	$NavigationAgent2D.target_position = player.global_position
	
	
func _on_timer_timeout() -> void:
	make_path()
	$Timer.start()
