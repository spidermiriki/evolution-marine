extends CanvasLayer
class_name EvolvePanel

signal evolution_chosen(target_id: String)

var _panel: Control
var _choices_container: HBoxContainer
var _visible_panel: bool = false

func _ready() -> void:
	_build()

func _build() -> void:
	# --- Panneau principal ---
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_panel.offset_top    = 0.0
	_panel.offset_bottom = 170.0
	_panel.visible = false
	add_child(_panel)

	# Fond semi-transparent
	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.04, 0.12, 0.88)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.add_child(bg)

	# Titre
	var label := Label.new()
	label.text = "✦  Choisis ton évolution  ✦"
	label.add_theme_color_override("font_color", Color("9fd8ff"))
	label.add_theme_font_size_override("font_size", 13)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_TOP_WIDE)
	label.offset_top    = 8.0
	label.offset_bottom = 32.0
	_panel.add_child(label)

	# Conteneur des choix (HBox centré)
	_choices_container = HBoxContainer.new()
	_choices_container.add_theme_constant_override("separation", 12)
	_choices_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices_container.set_anchors_preset(Control.PRESET_TOP_WIDE)
	_choices_container.offset_top    = 34.0
	_choices_container.offset_bottom = 165.0
	_panel.add_child(_choices_container)

	# Overlay "Transformation..."
	var overlay := Label.new()
	overlay.name = "EvolvingOverlay"
	overlay.text = "✦  Transformation en cours...  ✦"
	overlay.add_theme_color_override("font_color", Color("9fd8ff"))
	overlay.add_theme_font_size_override("font_size", 18)
	overlay.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	overlay.vertical_alignment   = VERTICAL_ALIGNMENT_CENTER
	overlay.set_anchors_preset(Control.PRESET_CENTER)
	overlay.offset_left   = -260.0
	overlay.offset_right  =  260.0
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
		if target.is_empty():
			continue
		var card := _make_card(cid, target)
		_choices_container.add_child(card)

	_panel.visible = true

func _make_card(sid: String, sp: Dictionary) -> Control:
	var cls: String     = sp.get("cls", "tank")
	var cls_color: Color = SpeciesDB.CLASS_COLOR.get(cls, Color.WHITE)
	var tier: int       = int(sp.get("tier", 1))
	var tier_color: Color = SpeciesDB.TIER_COLOR.get(tier, Color.WHITE)

	# Carte VBox
	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(92, 128)
	card.add_theme_constant_override("separation", 3)

	# Fond de carte
	var card_bg := Panel.new()
	card_bg.custom_minimum_size = Vector2(92, 128)
	card_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color           = Color(0.04, 0.08, 0.16, 0.9)
	card_style.border_color       = cls_color
	card_style.border_width_left  = 2
	card_style.border_width_right = 2
	card_style.border_width_top   = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left     = 8
	card_style.corner_radius_top_right    = 8
	card_style.corner_radius_bottom_right = 8
	card_style.corner_radius_bottom_left  = 8
	card_bg.add_theme_stylebox_override("panel", card_style)

	# Bouton emoji centré
	var btn := Button.new()
	btn.text = sp.get("emoji", "?")
	btn.custom_minimum_size = Vector2(92, 62)
	btn.focus_mode = Control.FOCUS_NONE
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0, 0, 0, 0)
	btn.add_theme_stylebox_override("normal",  btn_style)
	btn.add_theme_stylebox_override("pressed", btn_style)
	btn.add_theme_stylebox_override("hover",   btn_style)
	btn.add_theme_font_size_override("font_size", 28)
	btn.pressed.connect(_choose.bind(sid))
	card.add_child(btn)

	# Nom (autowrap pour les longs noms)
	var name_lbl := Label.new()
	name_lbl.text = sp.get("name", sid)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.custom_minimum_size = Vector2(88, 0)
	name_lbl.add_theme_font_size_override("font_size", 8)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(name_lbl)

	# Tier · classe
	var info_lbl := Label.new()
	info_lbl.text = "T%d · %s" % [tier, cls]
	info_lbl.add_theme_font_size_override("font_size", 8)
	info_lbl.add_theme_color_override("font_color", tier_color)
	info_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(info_lbl)

	# Wrapper pour superposer le fond et la carte
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(92, 128)
	wrapper.add_child(card_bg)
	wrapper.add_child(card)

	return wrapper

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
