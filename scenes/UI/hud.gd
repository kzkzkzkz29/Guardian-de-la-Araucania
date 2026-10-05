extends CanvasLayer

# Referencias exactas a tus 3 slots de corazones
@onready var corazon_1: AnimatedSprite2D = $MarginContainer/ContenedorCorazones/Corazon1/SpriteCorazon
@onready var corazon_2: AnimatedSprite2D = $MarginContainer/ContenedorCorazones/Corazon2/SpriteCorazon
@onready var corazon_3: AnimatedSprite2D = $MarginContainer/ContenedorCorazones/Corazon3/SpriteCorazon

# Lista de corazones en orden visual [0: Izquierda, 1: Centro, 2: Derecha]
var lista_corazones: Array[AnimatedSprite2D] = []

# Variable de prueba para simular vidas
var vidas_prueba: int = 3

func _ready() -> void:
	lista_corazones = [corazon_1, corazon_2, corazon_3]
	inicializar_hud(3)

# Rellena todos los corazones con color rojo brillante
func inicializar_hud(vidas_totales: int) -> void:
	for i in range(lista_corazones.size()):
		if i < vidas_totales:
			lista_corazones[i].play("lleno")
		else:
			lista_corazones[i].play("vacio")

# Función oficial de daño (llamada por el jugador)
func actualizar_corazones(vidas_restantes: int) -> void:
	# Si quedan 2 vidas -> se vacía el índice 2 (Corazón 3, derecha)
	# Si queda 1 vida   -> se vacía el índice 1 (Corazón 2, centro)
	# Si quedan 0 vidas -> se vacía el índice 0 (Corazón 1, izquierda)
	var indice_a_vaciar = vidas_restantes
	
	if indice_a_vaciar >= 0 and indice_a_vaciar < lista_corazones.size():
		lista_corazones[indice_a_vaciar].play("perder_vida")

# --- PRUEBA AISLADA EN LA ESCENA HUD ---
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Tecla 1: Quita un corazón de derecha a izquierda
		if event.keycode == KEY_1:
			if vidas_prueba > 0:
				vidas_prueba -= 1
				actualizar_corazones(vidas_prueba)
		
		# Tecla 2: Reinicia las 3 vidas a lleno para seguir probando
		elif event.keycode == KEY_2:
			vidas_prueba = 3
			inicializar_hud(vidas_prueba)
	
