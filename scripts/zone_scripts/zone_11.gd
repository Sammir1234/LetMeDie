extends Area2D

@export var zone_id: int = 11

func _on_body_entered(body):
	if body.name == "MainChar":
		body.current_zone = zone_id


func _on_body_exited(body):
	if body.name == "MainChar":
		if body.current_zone == zone_id:
			body.current_zone = -1
