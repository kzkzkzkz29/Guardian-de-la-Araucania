extends CanvasLayer

# Ruta de la futura pantalla del menú (cuando la creemos)
@export_file("*.tscn") var ruta_menu_principal: String = "res://scenes/UI/menu_principal.tscn"

# Referencias a los contenedores visuales principales (para la animación de entrada)
@onready var fondo_oscuro: ColorRect = $FondoOscuro
@onready var contenedor_centrado: CenterContainer = $ContenedorCentrado

# Referencias a los componentes de contenido de la tarjeta
@onready var label_titulo: Label = $ContenedorCentrado/TarjetaPanel/MargenInterno/ContenidoVertical/LabelTitulo
@onready var ilustracion_especie: TextureRect = $ContenedorCentrado/TarjetaPanel/MargenInterno/ContenidoVertical/IlustracionEspecie
@onready var label_nombre_especie: Label = $ContenedorCentrado/TarjetaPanel/MargenInterno/ContenidoVertical/LabelNombreEspecie
@onready var label_dato_curioso: Label = $ContenedorCentrado/TarjetaPanel/MargenInterno/ContenidoVertical/LabelDatoCurioso
@onready var boton_salir: Button = $ContenedorCentrado/TarjetaPanel/MargenInterno/ContenidoVertical/BotonSalir

func _ready() -> void:
	# Conectamos el clic del botón
	boton_salir.pressed.connect(_on_boton_salir_pressed)

# Función modular llamada desde la Meta
func mostrar_victoria(titulo: String, nombre: String, dato_educativo: String, textura: Texture2D = null) -> void:
	label_titulo.text = titulo
	label_nombre_especie.text = nombre
	label_dato_curioso.text = dato_educativo
	
	if textura != null:
		ilustracion_especie.texture = textura
		
	# Pequeña animación de entrada suave (fade-in) sobre los controles visibles
	fondo_oscuro.modulate.a = 0.0
	contenedor_centrado.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(fondo_oscuro, "modulate:a", 1.0, 0.3)
	tween.parallel().tween_property(contenedor_centrado, "modulate:a", 1.0, 0.4)

func _on_boton_salir_pressed() -> void:
	# Verificamos si la escena del menú ya fue creada en el proyecto
	if ResourceLoader.exists(ruta_menu_principal):
		print("Volviendo al Menú Principal")
		get_tree().change_scene_to_file(ruta_menu_principal)
	else:
		# Fallback seguro: mientras el menú no exista, reinicia limpiamente el nivel
		print("Menú aún no implementado. Recargando nivel para seguir probando")
		get_tree().reload_current_scene()
