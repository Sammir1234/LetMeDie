extends CharacterBody2D

# Параметры противника
@export var speed: float = 100.0 # Скорость движения
@export var patrol_distance: float = 150.0 # Максимальная дистанция патруля

var direction: int = 1 # Направление движения
var start_x: float # Стартовая точка

func _ready() -> void:
	start_x = global_position.x # Установка стартовой точки
	

func _physics_process(delta: float) -> void:
	velocity.x = speed * direction 
	move_and_slide()

	# Смена направления движения
	if global_position.x >= start_x + patrol_distance:
		direction = -1
	elif global_position.x <= start_x - patrol_distance:
		direction = 1
