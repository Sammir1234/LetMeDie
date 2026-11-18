extends Area2D

@onready var player = get_tree().current_scene.get_node("MainChar")

func _physics_process(_delta: float) -> void:
	if player == null or player.is_dead:
		return

	if check_spikes(player) or check_lava(player):
		player.die()

# Проверка касания шипов
func check_spikes(body: Node2D) -> bool:
	var tilemap = get_tree().current_scene.get_node("MapTiles")

	var local_position = tilemap.to_local(body.global_position)
	var cell = tilemap.local_to_map(local_position)

	var tile_data = tilemap.get_cell_tile_data(cell)

	if tile_data == null:
		return false

	return tile_data.get_custom_data("Spike")

# Проверка касания лавы
func check_lava(body: Node2D) -> bool:
	var tilemap = get_tree().current_scene.get_node("MapTiles")

	var points = [
		Vector2(0, 0),    # Центр
		Vector2(0, -16),  # Верх
		Vector2(0, 16),   # Низ
		Vector2(-16, 0),  # Лево
		Vector2(16, 0)   # Право
	]

	for point in points:
		var world_position = body.global_position + point
		var local_position = tilemap.to_local(world_position)
		var cell = tilemap.local_to_map(local_position)

		var tile_data = tilemap.get_cell_tile_data(cell)

		if tile_data != null and tile_data.get_custom_data("Lava"):
			return true

	return false
