extends StaticBody2D

# Referencia al área sensora hija
@onready var area_deteccion: Area2D = $AreaDeteccion

var jugador_en_rango: bool = false
var jugador_referencia: CharacterBody2D = null

func _ready() -> void:
	# Conectamos las señales del área hija por código
	area_deteccion.body_entered.connect(_on_area_deteccion_body_entered)
	area_deteccion.body_exited.connect(_on_area_deteccion_body_exited)

func _process(_delta: float) -> void:
	# Si el jugador está al lado del fuego y pulsa la Q
	if jugador_en_rango and Input.is_action_just_pressed("interactuar"):
		intentar_apagar_fuego()

func _on_area_deteccion_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = true
		jugador_referencia = body as CharacterBody2D
		
		# Si choca sin agua, le pasa su posición X para calcular el retroceso
		if not jugador_referencia.tiene_agua:
			jugador_referencia.recibir_dano(global_position.x)

func _on_area_deteccion_body_exited(body: Node2D) -> void:
	if body == jugador_referencia:
		jugador_en_rango = false
		jugador_referencia = null

func intentar_apagar_fuego() -> void:
	if jugador_referencia == null:
		return
		
	if jugador_referencia.tiene_agua:
		print("Fuego apagado")
		# El jugador gasta su agua (vuelve a su color normal)
		jugador_referencia.usar_agua()
		
		# El fuego se elimina completamente del nivel (desaparece el muro y el sprite)
		queue_free()
	else:
		print("No puedes apagar el fuego")
