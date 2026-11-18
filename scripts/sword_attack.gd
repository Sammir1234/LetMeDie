extends Area2D

# Сигнал для передачи игроку направления и силы отскока
signal bounce_requested(direction: Vector2)

# Параметры
const SIDE_OFFSET = 50.0 # Расстояние от игрока до меча при горизонтальной атаке
const VERTICAL_OFFSET = 50.0 # Расстояние от игрока до меча при вертикальной атаке

const BOUNCE_HORIZONTAL = 450.0 # Сила горизонтального отскока
const BOUNCE_VERTICAL = 500.0 # Сила вертикального отскока

# Переменные
@onready var anim: AnimatedSprite2D = $AttackAnimation # Ссылка на анимацию атаки
@onready var collision: CollisionShape2D = $CollisionShape2D # Ссылка на область обнаружения столкновений

var attack_direction: Vector2 = Vector2.RIGHT # Направление текущей атаки

var attacking: bool = false # Проверка, выполняется ли сейчас атака

var has_hit: bool = false # Проверка, было ли уже зарегистрировано попадание


func _ready() -> void:
	# Отключение обнаружения столкновений при запуске игры
	monitoring = false
	collision.disabled = true

	# Подключение сигнала столкновения с физическими телами
	body_entered.connect(_on_body_entered)
	# Подключение сигнала столкновения с другими Area2D
	area_entered.connect(_on_area_entered)
	# Подключение сигнала окончания анимации
	anim.animation_finished.connect(_on_animation_finished)


# Запуск атаки в заданном направлении
func start_attack(direction: Vector2) -> void:
	show()
	
	# Запрет на начало новой атаки до окончания предыдущей
	if attacking:
		return

	attacking = true
	has_hit = false

	# Сохраняем направление атаки
	attack_direction = direction

	# Устанавливаем начальное положение меча относительно игрока
	position = direction * SIDE_OFFSET

	# Выбираем анимацию и положение меча
	anim.flip_h = false
	rotation_degrees = 0
	anim.play("attack_short")

	if direction == Vector2.UP:
		rotation_degrees = -90
		position = Vector2(0, -VERTICAL_OFFSET)

	elif direction == Vector2.DOWN:
		rotation_degrees = 90
		position = Vector2(0, VERTICAL_OFFSET)

	else:
		# Горизонтальная атака
		rotation_degrees = 0
		anim.flip_h = direction == Vector2.LEFT
		position = direction * SIDE_OFFSET


	# Включение обнаружения столкновений
	collision.set_deferred("disabled", false)
	set_deferred("monitoring", true)


# Обработка столкновения с физическим телом
func _on_body_entered(body: Node2D) -> void:
	# Игнорирование игрока
	if body == get_parent():
		return

	# Регистрация попадания
	hit_target()


# Обработка столкновения с другой областью Area2D
func _on_area_entered(area: Area2D) -> void:
	if area == get_parent():
		return

	hit_target()


# Обработка попадания меча по объекту
func hit_target() -> void:
	# Проверка выполнения атаки и уже совершенной атаки
	if not attacking or has_hit:
		return

	has_hit = true

	# Направление отскока
	var bounce_direction = -attack_direction
	var impulse: Vector2
	
	# Расчет импульса
	if attack_direction == Vector2.LEFT or attack_direction == Vector2.RIGHT:
	# Горизонтальный удар: отскок по диагонали вверх
		impulse = Vector2(
			bounce_direction.x * BOUNCE_HORIZONTAL,
			-BOUNCE_VERTICAL
		)
	else:
		# Вертикальный удар: обычный отскок
		impulse = Vector2(
			bounce_direction.x * BOUNCE_HORIZONTAL,
			bounce_direction.y * BOUNCE_VERTICAL
		)

	# Сигнал игроку с рассчитанным импульсом
	bounce_requested.emit(impulse)

	# Завершение атаки после попадания
	stop_attack()
	await get_tree().create_timer(0.1).timeout
	hide()


# Завершение атаки
func stop_attack() -> void:
	attacking = false

	# Отключение обнаружения столкновений
	set_deferred("monitoring", false)
	collision.set_deferred("disabled", true)



func _on_animation_finished() -> void:
	# Завершение атаки, если нет попадания
	stop_attack()
	hide()
