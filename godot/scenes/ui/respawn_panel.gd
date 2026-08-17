extends CanvasLayer
class_name RespawnPanel

const P1_SPECIES: Array[String] = ["crabe", "sole", "aiguille"]

var _panel: Control
var _choices_container: HBoxContainer

func _ready() -> void:
	_build()

func _build() -> void:
	# Fond plein écran semi-transparent
	_panel = Control.new()
	_panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	_panel.visible = false
	add_child(_panel)

	var bg := ColorRect.new()
	bg.color = Color(0.0, 0.01, 0.06, 0.82)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.add_child(bg)

	# Titre
	var title := Label.new()
	title.text = "✦  Tu es mort — Choisis ton incarnation  ✦"
	title.add_theme_color_override("font_color", Color("ff8080"))
	title.add_theme_font_size_override("font_size", 16)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.set_anchors_preset(Control.PRESET_CENTER_TOP)
	title.offset_left   = -320.0
	title.offset_right  =  320.0
	title.offset_top    =   90.0
	title.offset_bottom =  120.0
	_panel.add_child(title)

	# Conteneur des cartes
	_choices_container = HBoxContainer.new()
	_choices_container.add_theme_constant_override("separation", 20)
	_choices_container.alignment = BoxContainer.ALIGNMENT_CENTER
	_choices_container.set_anchors_preset(Control.PRESET_CENTER)
	_choices_container.offset_left   = -220.0
	_choices_container.offset_right  =  220.0
	_choices_container.offset_top    =  -80.0
	_choices_container.offset_bottom =   90.0
	_panel.add_child(_choices_container)

	for sid in P1_SPECIES:
		var sp := SpeciesDB.get_species(sid)
		if sp.is_empty():
			continue
		_choices_container.add_child(_make_card(sid, sp))

	GameManager.respawn_needed.connect(_on_respawn_needed)

func _on_respawn_needed() -> void:
	_panel.visible = true

func _make_card(sid: String, sp: Dictionary) -> Control:
	var cls: String      = sp.get("cls", "tank")
	var cls_color: Color = SpeciesDB.CLASS_COLOR.get(cls, Color.WHITE)

	var card := VBoxContainer.new()
	card.custom_minimum_size = Vector2(100, 148)
	card.add_theme_constant_override("separation", 4)

	# Fond de carte
	var card_bg := Panel.new()
	card_bg.custom_minimum_size = Vector2(100, 148)
	card_bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	var card_style := StyleBoxFlat.new()
	card_style.bg_color           = Color(0.04, 0.08, 0.18, 0.92)
	card_style.border_color       = cls_color
	card_style.border_width_left  = 2
	card_style.border_width_right = 2
	card_style.border_width_top   = 2
	card_style.border_width_bottom = 2
	card_style.corner_radius_top_left     = 10
	card_style.corner_radius_top_right    = 10
	card_style.corner_radius_bottom_right = 10
	card_style.corner_radius_bottom_left  = 10
	card_bg.add_theme_stylebox_override("panel", card_style)

	# Bouton emoji
	var btn := Button.new()
	btn.text = sp.get("emoji", "?")
	btn.custom_minimum_size = Vector2(100, 76)
	btn.focus_mode = Control.FOCUS_NONE
	var btn_style := StyleBoxFlat.new()
	btn_style.bg_color = Color(0, 0, 0, 0)
	btn.add_theme_stylebox_override("normal",  btn_style)
	btn.add_theme_stylebox_override("pressed", btn_style)
	btn.add_theme_stylebox_override("hover",   btn_style)
	btn.add_theme_font_size_override("font_size", 34)
	btn.pressed.connect(_choose.bind(sid))
	card.add_child(btn)

	# Nom
	var name_lbl := Label.new()
	name_lbl.text = sp.get("name", sid)
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	name_lbl.custom_minimum_size = Vector2(96, 0)
	name_lbl.add_theme_font_size_override("font_size", 10)
	name_lbl.add_theme_color_override("font_color", Color.WHITE)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(name_lbl)

	# Classe
	var cls_lbl := Label.new()
	cls_lbl.text = cls
	cls_lbl.add_theme_font_size_override("font_size", 9)
	cls_lbl.add_theme_color_override("font_color", cls_color)
	cls_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	card.add_child(cls_lbl)

	# Wrapper pour superposer fond et contenu
	var wrapper := Control.new()
	wrapper.custom_minimum_size = Vector2(100, 148)
	wrapper.add_child(card_bg)
	wrapper.add_child(card)
	return wrapper

func _choose(sid: String) -> void:
	_panel.visible = false
	if GameManager.player != null:
		GameManager.player.complete_respawn(sid)
