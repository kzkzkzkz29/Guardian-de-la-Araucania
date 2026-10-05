extends CharacterBody2D

# --- PARÁMETROS CONFIGURABLES ---
@export_group("Físicas de Movimiento")
@export var speed: float = 160.0
@export var jump_velocity: float = -320.0

@export_group("Cámara Cinemática")
@export var factor_resorte_vertical: float = 0.22
@export var velocidad_camara: float = 5.0

@export_group("Sistema de Salud")
@export var vidas_maximas: int = 3
@export var fuerza_knockback_x: float = 180.0
@export var fuerza_knockback_y: float = -200.0

# Variables de Estado
var vidas: int = 3
var tiene_agua: bool = false
var es_invulnerable: bool = false

# Coordenada límite de la pared izquierda
const BORDE_PARED_IZQUIERDA: float = -224.0

# Referencias directas a nodos hijos
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area_2d: Area2D = $Area2D
@onready var camera_2d: Camera2D = $Camera2D
@onready var timer_invulnerabilidad: Timer = $TimerInvulnerabilidad

# Referencia a la animación de parpadeo (Tween)
var tween_dano: Tween

func _ready() -> void:
	vidas = vidas_maximas
	
	# Conexión del sensor de daño corporal
	if not area_2d.body_entered.is_connected(_on_area_2d_body_entered):
		area_2d.body_entered.connect(_on_area_2d_body_entered)

	# Conexión del temporizador de invulnerabilidad
	if timer_invulnerabilidad:
		timer_invulnerabilidad.timeout.connect(_on_timer_invulnerabilidad_timeout)

	# Inicialización de la cámara desacoplada
	if camera_2d:
		camera_2d.top_level = true
		camera_2d.make_current()
		var mitad_ancho = (get_viewport_rect().size.x / camera_2d.zoom.x) / 2.0
		camera_2d.global_position.x = max(global_position.x, BORDE_PARED_IZQUIERDA + mitad_ancho)
		camera_2d.global_position.y = global_position.y * factor_resorte_vertical

func _physics_process(delta: float) -> void:
	# 1. Gravedad continua
	if not is_on_floor():
		velocity += get_gravity() * delta

	# 2. Salto (solo si está en el suelo y no está aturdido en el aire)
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity

	# 3. Movimiento horizontal
	var direction: float = Input.get_axis("ui_left", "ui_right")

	if direction != 0.0:
		velocity.x = direction * speed
		if direction < 0.0:
			animated_sprite.scale.x = -abs(animated_sprite.scale.x)
		else:
			animated_sprite.scale.x = abs(animated_sprite.scale.x)
	else:
		velocity.x = move_toward(velocity.x, 0.0, speed)

	# 4. Control visual de animaciones
	gestionar_animaciones(direction)

	# 5. Resolver físicas y colisiones
	move_and_slide()

	# 6. Actualizar cámara cinematográfica
	actualizar_camara_cinematica(delta)

func actualizar_camara_cinematica(delta: float) -> void:
	if not camera_2d:
		return
	var mitad_ancho = (get_viewport_rect().size.x / camera_2d.zoom.x) / 2.0
	var x_minima = BORDE_PARED_IZQUIERDA + mitad_ancho
	var x_objetivo = max(global_position.x, x_minima)
	var y_objetivo = global_position.y * factor_resorte_vertical

	camera_2d.global_position.x = lerp(camera_2d.global_position.x, x_objetivo, velocidad_camara * delta)
	camera_2d.global_position.y = lerp(camera_2d.global_position.y, y_objetivo, velocidad_camara * delta)

func gestionar_animaciones(direction: float) -> void:
	if not is_on_floor():
		if velocity.y < 0.0:
			animated_sprite.play("saltar")
		else:
			animated_sprite.play("caer")
	elif direction != 0.0:
		animated_sprite.play("correr")
	else:
		animated_sprite.play("idle")

# --- SISTEMA DE COMBATE, DAÑO Y SALUD ---

func recibir_dano(posicion_amenaza_x: float = 0.0) -> void:
	# Si está en periodo de gracia de 1.5 segundos, ignora el golpe
	if es_invulnerable:
		return

	# 1. Restar vida
	vidas -= 1
	print("Impacto recibido Vidas restantes ", vidas)

	# 2. Notificar al HUD (busca cualquier nodo en el grupo 'hud')
	var nodo_hud = get_tree().get_first_node_in_group("hud")
	if nodo_hud and nodo_hud.has_method("actualizar_corazones"):
		nodo_hud.actualizar_corazones(vidas)

	# 3. Comprobar muerte y reinicio de escena
	if vidas <= 0:
		morir()
		return

	# 4. Activar estado de invulnerabilidad
	es_invulnerable = true
	timer_invulnerabilidad.start()

	# 5. Aplicar Retroceso (Knockback) físico hacia arriba y atrás
	aplicar_knockback(posicion_amenaza_x)

	# 6. Iniciar parpadeo en color rojo
	iniciar_parpadeo_dano()

func aplicar_knockback(posicion_amenaza_x: float) -> void:
	# Impulso vertical para despegarlo del suelo o pincho
	velocity.y = fuerza_knockback_y

	# Determinamos la dirección horizontal del empujón:
	# Si no se pasó coordenada, empuja en sentido opuesto a donde mira el sprite
	var direccion_empuje: float = -sign(animated_sprite.scale.x)
	if posicion_amenaza_x != 0.0:
		direccion_empuje = sign(global_position.x - posicion_amenaza_x)
		if direccion_empuje == 0.0:
			direccion_empuje = -1.0

	velocity.x = direccion_empuje * fuerza_knockback_x

func iniciar_parpadeo_dano() -> void:
	# Si había un parpadeo previo, lo cancelamos
	if tween_dano and tween_dano.is_valid():
		tween_dano.kill()

	tween_dano = create_tween().set_loops(6) # Parpadea 6 veces durante los 1.5 s
	# Cambia a rojo intenso
	tween_dano.tween_property(self, "modulate", Color(1.0, 0.2, 0.2, 0.6), 0.12)
	# Vuelve al color base (celeste si tiene agua, blanco si no)
	var color_retorno = Color(0.6, 0.8, 1.0) if tiene_agua else Color(1.0, 1.0, 1.0)
	tween_dano.tween_property(self, "modulate", color_retorno, 0.12)

func _on_timer_invulnerabilidad_timeout() -> void:
	# Finaliza el periodo de gracia
	es_invulnerable = false
	if tween_dano and tween_dano.is_valid():
		tween_dano.kill()

	# Restauramos el color original limpio
	modulate = Color(0.6, 0.8, 1.0) if tiene_agua else Color(1.0, 1.0, 1.0)
	print("Fin del periodo de invulnerabilidad.")

func morir() -> void:
	print("Sin vidas. Reiniciando nivel")
	# Desactivamos procesos para evitar acciones durante la recarga
	set_physics_process(false)
	
	# Recarga completa de la escena actual (restablece basuras, fuegos y posición)
	get_tree().reload_current_scene()

# --- DETECCIÓN DE AMENAZAS EXISTENTES ---

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Daño por pinchos o espinas del TileMap
	recibir_dano(body.global_position.x)

# --- SISTEMA DE AGUA ---

func recargar_agua() -> void:
	tiene_agua = true
	print("Personaje cargó agua! Listo para apagar incendios.")
	if not es_invulnerable:
		modulate = Color(0.6, 0.8, 1.0)

func usar_agua() -> void:
	tiene_agua = false
	print("Agua consumida al apagar el fuego.")
	if not es_invulnerable:
		modulate = Color(1.0, 1.0, 1.0)
