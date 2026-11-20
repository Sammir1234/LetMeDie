extends Area2D

@export var zone_id: int = 0

func _on_body_entered(body: Node2D):
	if body.name == "MainChar":
		body.current_zone = zone_id
		


func _on_body_exited(body: Node2D):
	if body.name == "MainChar":
		if body.current_zone == zone_id:
			body.current_zone = -1
