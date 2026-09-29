extends Area2D

@export var textura_plantada: Texture2D

@onready var sprite: Sprite2D = $Sprite2D

var ya_fue_plantado: bool = false
var jugador_en_rango: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if jugador_en_rango and Input.is_action_just_pressed("plantar"):
		intentar_plantar()

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = true
		print("El personaje se paró sobre la tierra")

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		jugador_en_rango = false
		print("El personaje salió de la tierra")

func intentar_plantar() -> void:
	if ya_fue_plantado:
		print("Esta zona ya tiene una semilla plantada")
		return
		
	ya_fue_plantado = true
	print("Semilla plantada")
	
	if textura_plantada != null:
		sprite.texture = textura_plantada
		# Restauramos el tinte blanco natural para ver la textura en sus colores reales
		sprite.modulate = Color(1.0, 1.0, 1.0)
	else:
		# Feedback temporal: Verde brillante de Greyboxing
		sprite.modulate = Color(0.2, 1.0, 0.3)
