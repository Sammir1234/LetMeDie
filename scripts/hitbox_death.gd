extends Area2D

#Звук смерти
@onready var audio: AudioStreamPlayer2D = $DeathSound
@onready var tile_map_layer: TileMapLayer  = get_tree().current_scene.get_node("MapTiles")
@onready var anim: AnimatedSprite2D = $CharAnimations

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	var tile_coords = tile_map_layer.local_to_map(
		tile_map_layer.to_local(global_position)
	)

	var is_hazard = tile_map_layer.get_custom_data("Threat", tile_coords)

	if is_hazard:
		audio.play()
		anim.play("death")
		await get_tree().create_timer(0.3).timeout
		get_tree().reload_current_scene()
