extends Area2D

# Variable de control: sabe si el jugador está encima o no
var jugador_en_rango: bool = false

func _ready() -> void:
	# Escuchamos tanto la entrada como la salida del personaje
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	# Si el jugador está dentro del área y presiona la tecla Q (acción 'interactuar')
	if jugador_en_rango and Input.is_action_just_pressed("interactuar"):
		recoger_basura()

func _on_body_entered(_body: Node2D) -> void:
	# El personaje entró en contacto con la basura
	jugador_en_rango = true

func _on_body_exited(_body: Node2D) -> void:
	# El personaje se alejó de la basura sin recogerla
	jugador_en_rango = false

func recoger_basura() -> void:
	print("Basura recogida")
	# Eliminamos la basura del nivel
	queue_free()
