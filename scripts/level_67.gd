extends Node2D

@onready var narrator_ui: CanvasLayer = $NarratorUI
@onready var message_label: Label = $NarratorUI/Panel/Label
@onready var music:  AudioStreamPlayer = $AudioStreamPlayer

func _ready() -> void:
	music.play()
	LevelManager.current_level = 3
