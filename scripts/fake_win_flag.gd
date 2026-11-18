extends Area2D

@export var speed: float = 1000

var player: Node2D = null

func _ready() -> void:
	player = get_tree().current_scene.find_child("MainChar", true, false) as Node2D
	body_entered.connect(_on_body_entered)

func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		return

	var direction = global_position.direction_to(player.global_position)
	global_position += direction * speed * delta

func _on_body_entered(body: Node2D) -> void:
	if body.name == "MainChar":
		await get_tree().create_timer(0.35).timeout
		get_tree().change_scene_to_file("res://levels/victory_screen.tscn")
