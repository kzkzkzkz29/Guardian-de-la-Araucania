extends StaticBody2D

# Referencias a nodos visuales y físicos
@onready var sprite_humo: AnimatedSprite2D = $SpriteHumo
@onready var sprite_fuego: AnimatedSprite2D = $SpriteFuego
@onready var colision_muro: CollisionShape2D = $CollisionShape2D
@onready var area_deteccion: Area2D = $AreaDeteccion
@onready var colision_sensor: CollisionShape2D = $AreaDeteccion/CollisionShape2D

var jugador_en_rango: bool = false
var jugador_referencia: CharacterBody2D = null
var esta_apagandose: bool = false

func _ready() -> void:
	sprite_fuego.play("arder")
	sprite_humo.play("humear")

	area_deteccion.body_entered.connect(_on_area_deteccion_body_entered)
	area_deteccion.body_exited.connect(_on_area_deteccion_body_exited)

func _process(_delta: float) -> void:
	if jugador_en_rango and Input.is_action_just_pressed("interactuar"):
		intentar_apagar_fuego()

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if esta_apagandose or not (body is CharacterBody2D):
		return

	jugador_en_rango = true
	jugador_referencia = body as CharacterBody2D

	# Daño y empujón si toca el fuego sin agua
	if not jugador_referencia.tiene_agua:
		jugador_referencia.recibir_dano(global_position.x)

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_referencia:
		jugador_en_rango = false
		jugador_referencia = null

func intentar_apagar_fuego() -> void:
	if jugador_referencia == null or esta_apagandose:
		return

	if jugador_referencia.tiene_agua:
		apagar_con_vapor_suave()
	else:
		print("No puedes apagar el fuego")

func apagar_con_vapor_suave() -> void:
	esta_apagandose = true
	print("Fuego extinguido")

	# 1. El jugador gasta su agua
	jugador_referencia.usar_agua()

	# 2. Desactivamos colisiones físicas al instante para no bloquear el paso
	colision_muro.set_deferred("disabled", true)
	colision_sensor.set_deferred("disabled", true)

	# 3. SECUENCIA CINEMÁTICA CON CURVAS SUAVES:
	var tween = create_tween()

	# A. Las llamas rojas se extinguen en 0.35 s
	tween.tween_property(sprite_fuego, "modulate:a", 0.0, 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# B. Transición progresiva del humo:
	# Pasa de su tono oscuro a un blanco vaporoso con tinte suave en 0.9 segundos
	var color_vapor_blanco = Color(1.0, 1.05, 1.1, 0.75)
	tween.parallel().tween_property(sprite_humo, "modulate", color_vapor_blanco, 0.9).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	# C. El vapor se eleva suavemente hacia arriba (16 px) durante 1.8 segundos
	var altura_final_vapor = sprite_humo.position.y - 16.0
	tween.parallel().tween_property(sprite_humo, "position:y", altura_final_vapor, 1.8).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# D. Desvanecimiento paulatino del vapor (se vuelve transparente en los últimos 1.2 segundos)
	tween.parallel().tween_property(sprite_humo, "modulate:a", 0.0, 1.2).set_delay(0.6).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)

	# E. Una vez que el vapor es 100% invisible, destruimos el nodo
	tween.tween_callback(queue_free)
