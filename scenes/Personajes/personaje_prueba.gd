extends CharacterBody2D


@export_group("Físicas de Movimiento")
@export var speed: float = 160.0
@export var jump_velocity: float = -320.0

@export_group("Cámara Cinemática")
@export var factor_resorte_vertical: float = 0.22  # Porcentaje elástico del salto (22%)
@export var velocidad_camara: float = 5.0          # Suavizado elástico continuo

# Estados del jugador

var tiene_agua: bool = false

# Coordenada física exacta de la pared izquierda (-14 celdas * 16 px = -224 px)

const BORDE_PARED_IZQUIERDA: float = -224.0

# Referencias directas a los nodos hijos de la escena

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var camera_2d: Camera2D = $Camera2D

func _ready() -> void:
	# 1. Conexión por código de la señal si no está conectada desde el editor
	if not area_2d.body_entered.is_connected(_on_area_2d_body_entered):
		area_2d.body_entered.connect(_on_area_2d_body_entered)

	# 2. Inicialización de la cámara desacoplada (top_level)
	if camera_2d:
		camera_2d.top_level = true  # Desacopla la cámara de la posición rígida del monito
		camera_2d.make_current()

		# Posición inicial: frena en la pared izquierda y centra en Y = 0
		var mitad_ancho_pantalla = (get_viewport_rect().size.x / camera_2d.zoom.x) / 2.0
		camera_2d.global_position.x = max(global_position.x, BORDE_PARED_IZQUIERDA + mitad_ancho_pantalla)
		camera_2d.global_position.y = global_position.y * factor_resorte_vertical


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

# 6. Actualizar seguimiento y resorte de cámara
	actualizar_camara_cinematica(delta)


func actualizar_camara_cinematica(delta: float) -> void:
	if not camera_2d:
		return

# Eje X: Sigue al jugador a la derecha y se detiene automáticamente en la pared izquierda
	var mitad_ancho = (get_viewport_rect().size.x / camera_2d.zoom.x) / 2.0
	var x_minima = BORDE_PARED_IZQUIERDA + mitad_ancho
	var x_objetivo = max(global_position.x, x_minima)

# Eje Y: Anclado en el centro del nivel (Y = 0) + resorte elástico proporcional a los saltos
	var y_objetivo = global_position.y * factor_resorte_vertical

# Amortiguación elástica continua sin topes rígidos
	camera_2d.global_position.x = lerp(camera_2d.global_position.x, x_objetivo, velocidad_camara * delta)
	camera_2d.global_position.y = lerp(camera_2d.global_position.y, y_objetivo, velocidad_camara * delta)


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

func _on_area_2d_body_entered(_body: Node2D) -> void:
# Verificación en consola al tocar pinchos u obstáculos sólidos
	print("Muerto")

# --- SISTEMA DE DAÑO Y SALUD ---

func recibir_dano() -> void:
# POR AHORA: imprime "Muerto"
	print("Te quemaste con el fuego")

# Función para recargar agua (llamada por el charco)

func recargar_agua() -> void:
	tiene_agua = true
	print("Personaje cargó agua")
# Feedback visual temporal: teñimos ligeramente al personaje de celeste/azul
	modulate = Color(0.6, 0.8, 1.0)

# Función para gastar el agua (la usará el fuego más adelante)

func usar_agua() -> void:
	tiene_agua = false
	print("Agua consumida al apagar el fuego")
# Volvemos a su color normal
	modulate = Color(1.0, 1.0, 1.0)
