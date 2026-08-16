extends CanvasLayer
class_name EvolvePanel

signal evolution_chosen(target_id: String)

var _panel: Control
var _choices_container: HBoxContainer
var _visible_panel: bool = false

func _ready() -> void:
	_build()

func _build() -> void:
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_panel.offset_top    = 10.0
	_panel.offset_bottom = 120.0
	_panel.visible = false
	add_child(_panel)

	var label := Label.new()
	label.text = "Le cristal t'appelle — choisis ton évolution"
	label.add_theme_color_override("font_color", Color.WHITE)
	label.add_theme_font_size_override("font_size", 12)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top    = 0.0
	label.offset_bottom = 30.0
	_panel.add_child(label)

	_choices_container = HBoxContainer.new()
	_choices_container.add_theme_constant_override("separation", 16)
	_choices_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_choices_container.offset_top    = 35.0
	_choices_container.offset_bottom = 100.0
	_panel.add_child(_choices_container)

	# Overlay d'évolution
	var overlay := Label.new()
	overlay.name = "EvolvingOverlay"
	overlay.text = "Transformation..."
	overlay.add_theme_color_override("font_color", Color.WHITE)
	overlay.add_theme_font_size_override("font_size", 16)
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	overlay.set_anchors_preset(Control.PRESET_CENTER)
	overlay.offset_left   = -200.0
	overlay.offset_right  =  200.0
	overlay.offset_top    =  -30.0
	overlay.offset_bottom =   30.0
	overlay.visible = false
	add_child(overlay)

	GameManager.evolve_ready.connect(_on_evolve_ready)
	GameManager.evolve_started.connect(_on_evolve_started)
	GameManager.evolve_finished.connect(_on_evolve_finished)
	GameManager.player_died.connect(_on_player_died)

func _on_evolve_ready(choices: Array) -> void:
	if _visible_panel:
		return
	_visible_panel = true
	for child in _choices_container.get_children():
		child.queue_free()

	for cid in choices:
		var target := SpeciesDB.get_species(cid)
		var btn := _make_choice_btn(cid, target)
		_choices_container.add_child(btn)

	_panel.visible = true

func _make_choice_btn(species_id: String, sp: Dictionary) -> Control:
	var container := Control.new()
	container.custom_minimum_size = Vector2(60, 70)

	var circle_btn := Button.new()
	circle_btn.text = sp.get("emoji", "?")
	circle_btn.custom_minimum_size = Vector2(52, 52)
	circle_btn.set_anchors_preset(Control.PRESET_TOP_WIDE)
	circle_btn.offset_bottom = 52.0

	var cls: String = sp.get("cls", "tank")
	var cls_color: Color = SpeciesDB.CLASS_COLOR.get(cls, Color.WHITE)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.04, 0.08, 0.14, 0.75)
	style.border_color = cls_color
	style.border_width_left   = 2
	style.border_width_right  = 2
	style.border_width_top    = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left     = 26
	style.corner_radius_top_right    = 26
	style.corner_radius_bottom_right = 26
	style.corner_radius_bottom_left  = 26
	circle_btn.add_theme_stylebox_override("normal",  style)
	circle_btn.add_theme_stylebox_override("pressed", style)
	circle_btn.add_theme_stylebox_override("hover",   style)
	circle_btn.add_theme_color_override("font_color", cls_color)
	circle_btn.add_theme_font_size_override("font_size", 22)

	circle_btn.pressed.connect(_choose.bind(species_id))
	container.add_child(circle_btn)

	var name_label := Label.new()
	name_label.text = sp.get("name", species_id)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_font_size_override("font_size", 9)
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	name_label.offset_top    = 54.0
	name_label.offset_bottom = 70.0
	container.add_child(name_label)

	return container

func _choose(target_id: String) -> void:
	_visible_panel = false
	_panel.visible = false
	evolution_chosen.emit(target_id)
	if GameManager.player != null:
		GameManager.player.start_evolve(target_id)

func _on_evolve_started() -> void:
	var overlay := get_node_or_null("EvolvingOverlay")
	if overlay:
		overlay.visible = true

func _on_evolve_finished(_new_id: String) -> void:
	var overlay := get_node_or_null("EvolvingOverlay")
	if overlay:
		overlay.visible = false

func _on_player_died() -> void:
	_visible_panel = false
	_panel.visible = false
