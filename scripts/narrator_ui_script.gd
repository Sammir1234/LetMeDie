extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var label: Label = $Panel/Label
@onready var audio: AudioStreamPlayer2D = $Panel/Label/AudioStreamPlayer2D
var character_pos: int = 0

func _ready() -> void:
	panel.hide()

func show_message(text: String) -> void:
	panel.show()
	character_pos = 0
	while character_pos < text.length():
		character_pos += 1
		audio.pitch_scale = randf_range(0.8, 1.2)
		await get_tree().create_timer(0.02).timeout
		audio.play()
		label.text = text.substr(0, character_pos)

func hide_message() -> void:
	panel.hide()
