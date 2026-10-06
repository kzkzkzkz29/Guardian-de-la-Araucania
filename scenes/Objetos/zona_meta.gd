extends Area2D

# Configuración editable desde el Inspector para cada nivel
@export_group("Datos del Nivel y Ficha Educativa")
@export var nombre_especie: String = "Copihue (Lapageria rosea)"
@export_multiline var dato_curioso: String = "Es la flor nacional de Chile. Crece en los bosques templados trepando por los árboles, y sus flores rojas alimentan al picaflor y a nuestro Monito del Monte."
@export var imagen_educativa: Texture2D
@export var textura_arbol_florecido: Texture2D

# Escena de la pantalla de victoria
@export var escena_victoria: PackedScene = preload("res://scenes/UI/pantalla_victoria.tscn")

# Referencias internas
@onready var sprite_arbol: Sprite2D = $SpriteArbol

var meta_completada: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if meta_completada or not (body is CharacterBody2D):
		return

	activar_victoria(body as CharacterBody2D)

func activar_victoria(jugador: CharacterBody2D) -> void:
	meta_completada = true
	print("META ALCANZADA ", nombre_especie)

	# 1. Congelar físicas y controles del monito (Protección de Fin de Nivel)
	congelar_jugador(jugador)

	# 2. Transformación visual del árbol sagrado
	hacer_florecer_arbol()

	# 3. Desplegar la Tarjeta Educativa con retraso dramático de medio segundo
	get_tree().create_timer(0.5).timeout.connect(mostrar_pantalla_victoria)

func congelar_jugador(jugador: CharacterBody2D) -> void:
	jugador.set_physics_process(false)
	jugador.velocity = Vector2.ZERO

	var sprite_monito = jugador.get_node_or_null("AnimatedSprite2D")
	if sprite_monito and sprite_monito.sprite_frames and sprite_monito.sprite_frames.has_animation("idle"):
		sprite_monito.play("idle")

func hacer_florecer_arbol() -> void:
	if textura_arbol_florecido != null:
		sprite_arbol.texture = textura_arbol_florecido
		sprite_arbol.modulate = Color(1.0, 1.0, 1.0)
	else:
		sprite_arbol.modulate = Color(0.2, 1.0, 0.4)

	var tween = create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite_arbol, "scale", sprite_arbol.scale * 1.3, 0.4)

func mostrar_pantalla_victoria() -> void:
	if escena_victoria == null:
		return

	# Instanciamos la tarjeta en pantalla
	var pantalla = escena_victoria.instantiate()
	get_tree().current_scene.add_child(pantalla)

	# Rellenamos los datos del nivel actual
	pantalla.mostrar_victoria("NIVEL RESTAURADO", nombre_especie, dato_curioso, imagen_educativa)
