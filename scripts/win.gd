extends Area2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "MainChar":
		await get_tree().create_timer(0.35).timeout
		get_tree().change_scene_to_file("res://levels/victory_screen.tscn")
