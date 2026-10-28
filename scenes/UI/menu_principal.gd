extends Control

# Rutas de los niveles del juego
@export_file("*.tscn") var ruta_nivel_1: String = "res://scenes/nivel_1/nivel_1.tscn"
@export_file("*.tscn") var ruta_nivel_2: String = "res://scenes/nivel_2/nivel_2.tscn"
@export_file("*.tscn") var ruta_nivel_3: String = "res://scenes/nivel_3/nivel_3.tscn"

# Referencias a los contenedores de vistas
@onready var panel_inicio: VBoxContainer = $ContenedorCentrado/ContenedorGlobal/PanelInicio
@onready var panel_niveles: VBoxContainer = $ContenedorCentrado/ContenedorGlobal/PanelNiveles
@onready var panel_opciones: VBoxContainer = $ContenedorCentrado/ContenedorGlobal/PanelOpciones

# Botones de Inicio
@onready var boton_jugar: Button = $ContenedorCentrado/ContenedorGlobal/PanelInicio/BotonJugar
@onready var boton_opciones: Button = $ContenedorCentrado/ContenedorGlobal/PanelInicio/BotonOpciones
@onready var boton_salir: Button = $ContenedorCentrado/ContenedorGlobal/PanelInicio/BotonSalir

# Botones de Niveles
@onready var boton_nivel_1: Button = $ContenedorCentrado/ContenedorGlobal/PanelNiveles/BotonNivel1
@onready var boton_nivel_2: Button = $ContenedorCentrado/ContenedorGlobal/PanelNiveles/BotonNivel2
@onready var boton_nivel_3: Button = $ContenedorCentrado/ContenedorGlobal/PanelNiveles/BotonNivel3
@onready var boton_volver_niveles: Button = $ContenedorCentrado/ContenedorGlobal/PanelNiveles/BotonVolverNiveles

# Opciones de Audio
@onready var check_musica: CheckButton = $ContenedorCentrado/ContenedorGlobal/PanelOpciones/CheckMusica
@onready var check_sfx: CheckButton = $ContenedorCentrado/ContenedorGlobal/PanelOpciones/CheckSFX
@onready var boton_volver_opciones: Button = $ContenedorCentrado/ContenedorGlobal/PanelOpciones/BotonVolverOpciones

func _ready() -> void:
	# Aseguramos el estado visual inicial
	mostrar_panel("inicio")
	
	# Conexiones de navegación de Inicio
	boton_jugar.pressed.connect(_on_boton_jugar_pressed)
	boton_opciones.pressed.connect(_on_boton_opciones_pressed)
	boton_salir.pressed.connect(_on_boton_salir_pressed)
	
	# Conexiones de Niveles
	boton_nivel_1.pressed.connect(_on_boton_nivel_1_pressed)
	boton_nivel_2.pressed.connect(_on_boton_nivel_2_pressed)
	boton_nivel_3.pressed.connect(_on_boton_nivel_3_pressed)
	boton_volver_niveles.pressed.connect(_on_boton_volver_pressed)
	
	# Conexiones de Opciones
	check_musica.toggled.connect(_on_check_musica_toggled)
	check_sfx.toggled.connect(_on_check_sfx_toggled)
	boton_volver_opciones.pressed.connect(_on_boton_volver_pressed)

# Conmutador centralizado de paneles
func mostrar_panel(nombre_panel: String) -> void:
	panel_inicio.visible = (nombre_panel == "inicio")
	panel_niveles.visible = (nombre_panel == "niveles")
	panel_opciones.visible = (nombre_panel == "opciones")

# --- ACCIONES DE INICIO ---

func _on_boton_jugar_pressed() -> void:
	mostrar_panel("niveles")

func _on_boton_opciones_pressed() -> void:
	mostrar_panel("opciones")

func _on_boton_salir_pressed() -> void:
	print("👋 [Sistema] Saliendo de Guardián de la Araucanía...")
	get_tree().quit()

func _on_boton_volver_pressed() -> void:
	mostrar_panel("inicio")

# --- SELECCIÓN Y CARGA DE NIVELES ---

func _on_boton_nivel_1_pressed() -> void:
	cargar_nivel(ruta_nivel_1, "Nivel 1 (Bosque de Día)")

func _on_boton_nivel_2_pressed() -> void:
	cargar_nivel(ruta_nivel_2, "Nivel 2 (Bosque de Noche)")

func _on_boton_nivel_3_pressed() -> void:
	cargar_nivel(ruta_nivel_3, "Nivel 3 (Bosque al Atardecer)")

func cargar_nivel(ruta: String, nombre: String) -> void:
	if ResourceLoader.exists(ruta):
		print("🚀 [Escena] Cargando: ", nombre)
		get_tree().change_scene_to_file(ruta)
	else:
		print("⚠️ [Aviso] El archivo de '", nombre, "' aún está en construcción en: ", ruta)

# --- CONTROL DE AUDIO (Preparado para la Fase de Sonido) ---

func _on_check_musica_toggled(activado: bool) -> void:
	print("🎵 Música ambiental: ", "Activada" if activado else "Silenciada")
	# Nota: Cuando creemos los buses de audio, conectaremos:
	# AudioServer.set_bus_mute(AudioServer.get_bus_index("Music"), not activado)

func _on_check_sfx_toggled(activado: bool) -> void:
	print("🔊 Efectos SFX: ", "Activados" if activado else "Silenciados")
	# Nota: AudioServer.set_bus_mute(AudioServer.get_bus_index("SFX"), not activado)
