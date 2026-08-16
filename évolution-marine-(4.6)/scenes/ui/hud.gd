extends CanvasLayer
class_name HUD

var _species_label: Label
var _tier_label: Label
var _hp_bar: ProgressBar
var _xp_bar: ProgressBar
var _stamina_ring: Control
var _boost_btn: Button
var _ability_btn: Button
var _joystick: VirtualJoystick
var _death_overlay: ColorRect

var _stamina: float = 100.0
var _death_flash: float = 0.0
var _exhausted_flash: float = 0.0

func _ready() -> void:
	_build_ui()
	_connect_signals()

func _build_ui() -> void:
	# --- HUD haut ---
	var top_panel := VBoxContainer.new()
	top_panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	top_panel.offset_left  = 16.0
	top_panel.offset_top   = 14.0
	top_panel.add_theme_constant_override("separation", 6)
	add_child(top_panel)

	_species_label = Label.new()
	_species_label.text = "🦀 Crabe"
	_species_label.add_theme_color_override("font_color", Color.WHITE)
	_species_label.add_theme_font_size_override("font_size", 15)
	top_panel.add_child(_species_label)

	_tier_label = Label.new()
	_tier_label.text = "Tier 1 · tank"
	_tier_label.add_theme_color_override("font_color", Color("9fd8ff"))
	_tier_label.add_theme_font_size_override("font_size", 11)
	top_panel.add_child(_tier_label)

	_hp_bar = _make_bar(Color("ff4d4d"), Color("ff8080"))
	top_panel.add_child(_hp_bar)

	_xp_bar = _make_bar(Color("5fd1ff"), Color("8b5cff"))
	top_panel.add_child(_xp_bar)

	# --- Joystick ---
	_joystick = preload("res://scenes/ui/virtual_joystick.gd").new()
	add_child(_joystick)

	# --- Bouton Boost ---
	_boost_btn = _make_circle_button("BOOST", 75.0, Color("ff9d2f"), Color("ffe27a"))
	_boost_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_boost_btn.offset_left   = -107.0
	_boost_btn.offset_top    = -119.0
	_boost_btn.offset_right  = -32.0
	_boost_btn.offset_bottom = -44.0
	add_child(_boost_btn)

	# --- Ring stamina (dessin custom) ---
	_stamina_ring = Control.new()
	_stamina_ring.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_stamina_ring.offset_left   = -117.0
	_stamina_ring.offset_top    = -129.0
	_stamina_ring.offset_right  = -22.0
	_stamina_ring.offset_bottom = -34.0
	_stamina_ring.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stamina_ring.draw.connect(_draw_stamina_ring)
	add_child(_stamina_ring)

	# --- Bouton Capacité (crabe uniquement) ---
	_ability_btn = _make_circle_button("✂️", 75.0, Color("6b21a8"), Color("a855f7"))
	_ability_btn.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	_ability_btn.offset_left   = -200.0
	_ability_btn.offset_top    = -119.0
	_ability_btn.offset_right  = -125.0
	_ability_btn.offset_bottom = -44.0
	_ability_btn.visible = false
	add_child(_ability_btn)

	# --- Overlay mort ---
	_death_overlay = ColorRect.new()
	_death_overlay.color = Color(1, 0.08, 0.08, 0.0)
	_death_overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	_death_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_death_overlay)

	# --- Aide contrôles PC ---
	var pc_help := Label.new()
	pc_help.text = "Souris · diriger & nager    Shift · boost    Clic gauche · attaquer (crabe/baliste)"
	pc_help.add_theme_color_override("font_color", Color(1, 1, 1, 0.45))
	pc_help.add_theme_font_size_override("font_size", 11)
	pc_help.mouse_filter = Control.MOUSE_FILTER_IGNORE
	pc_help.set_anchors_preset(Control.PRESET_BOTTOM_LEFT)
	pc_help.offset_left   = 16.0
	pc_help.offset_bottom = -8.0
	pc_help.offset_top    = -24.0
	pc_help.offset_right  = 600.0
	add_child(pc_help)

func _make_bar(color_a: Color, color_b: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.min_value = 0.0
	bar.max_value = 100.0
	bar.value = 100.0
	bar.custom_minimum_size = Vector2(280, 10)
	bar.show_percentage = false
	var style_bg := StyleBoxFlat.new()
	style_bg.bg_color = Color(1, 1, 1, 0.15)
	style_bg.corner_radius_top_left = 6
	style_bg.corner_radius_top_right = 6
	style_bg.corner_radius_bottom_right = 6
	style_bg.corner_radius_bottom_left = 6
	bar.add_theme_stylebox_override("background", style_bg)
	var style_fill := StyleBoxFlat.new()
	style_fill.bg_color = color_a
	style_fill.corner_radius_top_left = 6
	style_fill.corner_radius_top_right = 6
	style_fill.corner_radius_bottom_right = 6
	style_fill.corner_radius_bottom_left = 6
	bar.add_theme_stylebox_override("fill", style_fill)
	return bar

func _make_circle_button(label: String, size: float,
		color_a: Color, _color_b: Color) -> Button:
	var btn := Button.new()
	btn.text = label
	btn.custom_minimum_size = Vector2(size, size)
	btn.focus_mode = Control.FOCUS_NONE  # évite que le bouton capte Espace/Entrée au clavier
	var style := StyleBoxFlat.new()
	style.bg_color = color_a
	style.corner_radius_top_left     = int(size / 2)
	style.corner_radius_top_right    = int(size / 2)
	style.corner_radius_bottom_right = int(size / 2)
	style.corner_radius_bottom_left  = int(size / 2)
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_stylebox_override("hover", style)
	return btn

func _connect_signals() -> void:
	GameManager.hp_changed.connect(_on_hp_changed)
	GameManager.xp_changed.connect(_on_xp_changed)
	GameManager.stamina_changed.connect(_on_stamina_changed)
	GameManager.species_changed.connect(_on_species_changed)
	GameManager.player_died.connect(_on_player_died)

	_boost_btn.button_down.connect(func(): _set_boost(true))
	_boost_btn.button_up.connect(func(): _set_boost(false))
	_ability_btn.button_down.connect(_on_ability_pressed)

func get_joystick() -> VirtualJoystick:
	return _joystick

func get_boost_active() -> bool:
	return _boost_btn.button_pressed

func _set_boost(state: bool) -> void:
	if GameManager.player != null:
		GameManager.player.boost_active = state

func _on_ability_pressed() -> void:
	if GameManager.player != null:
		GameManager.player.trigger_claw_attack()

func _on_hp_changed(hp: int, max_hp: int) -> void:
	_hp_bar.max_value = max_hp
	_hp_bar.value     = hp

func _on_xp_changed(xp: int, max_xp: int) -> void:
	_xp_bar.max_value = max_xp
	_xp_bar.value     = xp

func _on_stamina_changed(value: float) -> void:
	var was_zero := _stamina <= 0.0
	_stamina = value
	# Déclenche un flash rouge si la stamina vient de s'épuiser
	if _stamina <= 0.0 and not was_zero:
		_exhausted_flash = 1.0
	_stamina_ring.queue_redraw()

func _on_species_changed(species_id: String) -> void:
	var sp := SpeciesDB.get_species(species_id)
	_species_label.text = sp.get("emoji", "") + " " + sp.get("name", species_id)
	_tier_label.text    = "Tier %d · %s" % [sp.get("tier", 1), sp.get("cls", "")]
	_ability_btn.visible = sp.get("manual_attack", false)

func _on_player_died() -> void:
	_death_flash_start()

func _death_flash_start() -> void:
	_death_flash = 1.0

func _process(delta: float) -> void:
	if _death_flash > 0.0:
		_death_flash = max(0.0, _death_flash - delta * 1.8)
		_death_overlay.color.a = _death_flash * 0.45
	if _exhausted_flash > 0.0:
		_exhausted_flash = max(0.0, _exhausted_flash - delta * 2.5)
		_stamina_ring.queue_redraw()

func _draw_stamina_ring() -> void:
	var center := Vector2(47.5, 47.5)
	var r := 42.0
	var start := -PI / 2.0
	var end   := start + (_stamina / 100.0) * TAU

	# Anneau épuisé : fond rouge clignotant
	if _exhausted_flash > 0.0:
		var pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.015)
		_stamina_ring.draw_arc(center, r, -PI / 2.0, -PI / 2.0 + TAU, 48,
			Color(1.0, 0.2, 0.2, _exhausted_flash * pulse), 5.0, true)

	# Anneau normal (bleu → gris si épuisé)
	var ring_color := Color("5fe0ff") if _stamina > 0.01 else Color(0.4, 0.4, 0.4, 0.5)
	_stamina_ring.draw_arc(center, r, start, end, 48, ring_color, 5.0, true)
