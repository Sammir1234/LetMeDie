extends CharacterBody2D

# Параметры
# Базовое движение
const SPEED = 300.0 # Скорость
const ACCELERATION = 800.0 # Ускорение
const FRICTION = 1000.0 # Торможение
const JUMP_VELOCITY = -400.0 # Сила прыжка

# Параметры отпрыгивания от стены
const WALL_JUMP_VELOCITY = -400.0 # Сила прыжка при отпрыгивании
const WALL_JUMP_PUSH = 300.0 # Сила отталкивания от стены
const WALL_JUMP_LOCK_TIME = 0.1 # Задержка при отпрыгивании

var wall_jump_direction = 0.0
var wall_jump_timer = 0.0

# Параметры удара мечом
const ATTACK_COOLDOWN = 0.5 # Перезарядка атаки
var can_attack: bool = true # Возможность атаки
var is_bouncing: bool = false # Проверка отталкивания

var can_move: bool = true # Блокировка и разблокировка управления
var is_dead: bool = false # Флаг смерти

const DIRECTION_MEMORY_TIME = 250 # Время памяти направления атаки
var last_vertical_direction = Vector2.ZERO # Направление вертикальной атаки
var last_vertical_press_time = 0

# Текущая зона
var current_zone: int = -1

# Атака мечом
@onready var sword_attack = $SwordAttack


# Время койота
@onready var coyote_time: Timer = $CoyoteTime
# Проверка нахождения на земле
var was_on_floor = false

# Анимации персонажа
@onready var animated_sprite = $CharAnimations

# Звуки персонажа
@onready var audio_land = $Audio/Land # Приземление
@onready var audio_jump = $Audio/Jump # Прыжок
@onready var audio_death = $Audio/DeathSound # Прыжок

func _ready() -> void:
	sword_attack.bounce_requested.connect(_on_bounce_requested)

# Смерть
func die() -> void:
	if is_dead:
		return
	
	is_dead = true
	print(current_zone)
	if current_zone != -1:
		Global.register_zone_death(current_zone)
		
	print(Global.zone_death_count)
	
	velocity = Vector2.ZERO
	set_physics_process(false)
	
	can_move = false
	can_attack = false
	
	#  Проигрыш звука смерти
	audio_death.play()
	
	# Проигрыш анимации смерти
	animated_sprite.play("death")
	
	$CollisionShape2D.set_deferred("disabled", true)
	
	await get_tree().create_timer(1).timeout
	
	# Перезагрузка сцены
	get_tree().reload_current_scene()

func get_attack_direction() -> Vector2:
	if Input.is_action_pressed("ui_up"):
		return Vector2.UP

	if Input.is_action_pressed("ui_down"):
		return Vector2.DOWN

	if Time.get_ticks_msec() - last_vertical_press_time < DIRECTION_MEMORY_TIME:
		return last_vertical_direction

	if animated_sprite.flip_h:
		return Vector2.LEFT

	return Vector2.RIGHT

# Выполнение атаки мечом
func attack() -> void:
	# Проверка доступности атаки
	if not can_attack:
		return
	
	can_attack = false

	# Запуск атаки в определённом направлении
	sword_attack.start_attack(get_attack_direction())

	# Ожидание перезарядки
	await get_tree().create_timer(ATTACK_COOLDOWN).timeout

	can_attack = true

# Обработка отскока
func _on_bounce_requested(impulse: Vector2) -> void:
	if sword_attack.attack_direction == Vector2.DOWN:
		velocity.y = impulse.y
	else:
		velocity = impulse
	
	is_bouncing = true
	await get_tree().create_timer(0.2).timeout
	is_bouncing = false

func _physics_process(delta: float) -> void:
	var on_floor = is_on_floor()
	
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)

		var collider = collision.get_collider()

		# Проверяем, что столкновение произошло с TileMapLayer
		if collision.get_collider().name == "TileMapTraps":
			die()
		if collision.get_collider().name == "WinFlag":
			await get_tree().create_timer(0.35).timeout
			get_tree().change_scene_to_file("res://levels/victory_screen.tscn")
	
	if Input.is_action_just_pressed("ui_up"):
		last_vertical_direction = Vector2.UP
		last_vertical_press_time = Time.get_ticks_msec()

	elif Input.is_action_just_pressed("ui_down"):
		last_vertical_direction = Vector2.DOWN
		last_vertical_press_time = Time.get_ticks_msec()
	
	# Гравитация
	if can_move == false:
		velocity.x = 0
		move_and_slide()
		return
	
	if Input.is_action_just_pressed("attack"):
		attack()
	
	if not is_on_floor():
		velocity += get_gravity() * delta

	if is_on_floor() and not was_on_floor:
		audio_land.play()

	# Запуск таймера при сходе с платформы
	if was_on_floor and not on_floor:
		coyote_time.start()
	# Отключение таймера при нахождении на платформе 
	if is_on_floor():
		coyote_time.stop()
	was_on_floor = on_floor
	
	# Прыжок
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or not coyote_time.is_stopped():
			audio_jump.play()
			velocity.y = JUMP_VELOCITY
			coyote_time.stop()

	# Выбор направления движения
	if is_bouncing:
		pass
	else:
		var direction := Input.get_axis("ui_left", "ui_right")

		if direction != 0:
			animated_sprite.play("walk")
			
			velocity.x = move_toward(
				velocity.x,
				direction * SPEED,
				ACCELERATION * delta
			)
			if direction < 0:
				animated_sprite.flip_h = true
			elif direction > 0:
				animated_sprite.flip_h = false
		else:
			animated_sprite.play("idle")
			velocity.x = move_toward(
				velocity.x,
				0,
				FRICTION * delta
			)

	move_and_slide()
