extends Area2D

# Variable para saber si el jugador está dentro del agua
var jugador_en_rango: bool = false
# Guardamos la referencia directa al personaje para poder llamar su función
var jugador_referencia: CharacterBody2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Si el jugador está sobre el charco y presiona la tecla Q
	if jugador_en_rango and Input.is_action_just_pressed("interactuar"):
		intentar_cargar_agua()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = true
		jugador_referencia = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == jugador_referencia:
		jugador_en_rango = false
		jugador_referencia = null

func intentar_cargar_agua() -> void:
	if jugador_referencia != null:
		# Verificamos si ya tenía agua para no sobrecargarlo innecesariamente
		if jugador_referencia.tiene_agua:
			print("Ya tienes agua cargada")
		else:
			jugador_referencia.recargar_agua()
