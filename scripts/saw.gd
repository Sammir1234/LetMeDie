extends StaticBody2D

@onready var animated_sprite: AnimatedSprite2D = $SawAnimation

func _ready() -> void:
	animated_sprite.play("brrrrrrrrrr")

func _process(delta: float) -> void:
	pass
