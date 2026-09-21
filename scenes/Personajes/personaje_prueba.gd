extends CharacterBody2D

# --- PARÁMETROS CONFIGURABLES EN EL INSPECTOR ---
@export var speed: float = 160.0
@export var jump_velocity: float = -320.0

# Referencia al nodo hijo AnimatedSprite2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var area_2d = Area2D

func _ready():
	area_2d.body_entered.connect(_on_area_2d_body_entered)

func _physics_process(delta: float) -> void:
	# 1. Aplicar gravedad continua si el personaje está en el aire
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Manejo del salto usando la acción nativa de Godot ("ui_accept" = Barra Espaciadora / Enter)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Movimiento horizontal con acciones nativas ("ui_left" y "ui_right" = Flechas y teclas predeterminadas)
	var direction: float = Input.get_axis("ui_left", "ui_right")

	if direction != 0.0:
		velocity.x = direction * speed
		# Voltear horizontalmente el sprite según la dirección hacia la que avanza
		animated_sprite.flip_h = (direction < 0.0)
	else:
		# Frenado suave cuando se sueltan las teclas
		velocity.x = move_toward(velocity.x, 0.0, speed)

	# 4. Actualizar estado visual de las animaciones
	gestionar_animaciones(direction)

	# 5. Resolver colisiones y físicas nativas de Godot 4
	move_and_slide()

func gestionar_animaciones(direction: float) -> void:
	if not is_on_floor():
		# En el aire: subiendo con impulso o cayendo por gravedad
		if velocity.y < 0.0:
			animated_sprite.play("saltar")
		else:
			animated_sprite.play("caer")
	elif direction != 0.0:
		# En el suelo y en movimiento
		animated_sprite.play("correr")
	else:
		# En el suelo y quieto
		animated_sprite.play("idle")


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Muerto")
