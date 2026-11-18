extends Control

# Сцена последнего уровня
const LAST_LEVEL = "res://levels/level_67.tscn"

# Привязка функций к кнопкам
func _ready() -> void:
	$CenterContainer/VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$CenterContainer/VBoxContainer/CreditsButton.pressed.connect(_on_settings_pressed)
	$CenterContainer/VBoxContainer/ExitButton.pressed.connect(_on_exit_pressed)

# Функции при нажатии на кнопки
func _on_play_pressed() -> void:
	get_tree().change_scene_to_file(LAST_LEVEL)

func _on_settings_pressed() -> void:
	print("Открытие кредита")

func _on_exit_pressed() -> void:
	get_tree().quit()
