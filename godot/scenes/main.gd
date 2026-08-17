extends Node
class_name Main

# Fond qui change selon la profondeur (position Y caméra)
var _bg: ColorRect
var _hud: HUD
var _start_menu: StartMenu
var _evolve_panel: EvolvePanel

func _ready() -> void:
	_build_background()
	_build_world()
	_build_ui()

func _build_background() -> void:
	# CanvasLayer derrière tout
	var layer := CanvasLayer.new()
	layer.layer = -10
	add_child(layer)

	_bg = ColorRect.new()
	_bg.color = Color("021a2e")
	_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_bg)

func _build_world() -> void:
	var world_scene := preload("res://scenes/world/world.tscn")
	var world := world_scene.instantiate()
	add_child(world)

func _build_ui() -> void:
	_hud = preload("res://scenes/ui/hud.gd").new()
	_hud.layer = 5
	add_child(_hud)

	_evolve_panel = preload("res://scenes/ui/evolve_panel.gd").new()
	_evolve_panel.layer = 10
	add_child(_evolve_panel)

	var respawn_panel := preload("res://scenes/ui/respawn_panel.gd").new()
	respawn_panel.layer = 15
	add_child(respawn_panel)

	_start_menu = preload("res://scenes/ui/start_menu.gd").new()
	_start_menu.layer = 20
	_start_menu.species_selected.connect(_on_species_selected)
	add_child(_start_menu)

	# Connecter le joystick au joueur
	_hud.get_joystick().direction_changed.connect(_on_joystick_direction)

	GameManager.player_died.connect(_on_player_died)

func _on_species_selected(species_id: String) -> void:
	if GameManager.player != null:
		GameManager.player.change_species(species_id)

func _on_joystick_direction(vec: Vector2) -> void:
	if GameManager.player != null:
		GameManager.player.joystick_vec = vec

func _on_player_died() -> void:
	# Réinitialiser les barres HUD via signaux déjà émis dans player.change_species
	pass

func _process(_delta: float) -> void:
	if GameManager.player != null:
		var p := GameManager.player as CharacterBody2D
		if p:
			_bg.color = _depth_color(p.global_position.y)

func _depth_color(world_y: float) -> Color:
	var t: float = clampf(world_y / 3000.0, 0.0, 1.0)
	return Color(
		lerpf(0.51, 0.008, t),
		lerpf(0.843, 0.039, t),
		lerpf(1.0, 0.118, t)
	)
