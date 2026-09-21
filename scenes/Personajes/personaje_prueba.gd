extends CharacterBody2D

# --- PARÁMETROS CONFIGURABLES EN EL INSPECTOR ---
@export var speed: float = 160.0
@export var jump_velocity: float = -320.0

# Referencias directas a los nodos hijos de la escena
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D

func _ready() -> void:
	# Conexión por código de la señal si no está conectada desde el editor
	if not area_2d.body_entered.is_connected(_on_area_2d_body_entered):
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
		
		# --- SOLUCIÓN DE SIMETRÍA (scale.x) ---
		# En lugar de flip_h, invertimos scale.x para que el sprite gire sobre el eje central (X = 0)
		# sin desfasar el rectángulo celeste de colisión.
		if direction < 0.0:
			animated_sprite.scale.x = -abs(animated_sprite.scale.x)
		else:
			animated_sprite.scale.x = abs(animated_sprite.scale.x)
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
	# Verificación en consola al tocar pinchos u obstáculos sólidos
	print("Muerto")
