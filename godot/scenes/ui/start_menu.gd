extends CanvasLayer
class_name StartMenu

signal species_selected(species_id: String)

# Ordre d'affichage par palier
var _tier_species: Dictionary = {
	1: ["crabe", "sole", "aiguille"],
	2: ["poisson_globe", "raie", "lotte", "maquereau"],
	3: ["baliste", "murene", "bonite"],
	4: ["merou_geant", "wobbegong", "barracuda"],
}
var _tier_labels: Dictionary = {
	1: "Palier 1 — Débutant",
	2: "Palier 2 — Intermédiaire",
	3: "Palier 3 — Avancé  (se débloque en atteignant ce palier en jeu)",
	4: "Palier 4 — Maître  (se débloque en atteignant ce palier en jeu)",
}

func _ready() -> void:
	_build()

func _build() -> void:
	# Fond
	var bg := ColorRect.new()
	bg.color = Color(0.008, 0.102, 0.18, 0.95)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	# Conteneur principal
	var outer := VBoxContainer.new()
	outer.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer.offset_left   = 24.0
	outer.offset_top    = 20.0
	outer.offset_right  = -24.0
	outer.offset_bottom = -20.0
	outer.add_theme_constant_override("separation", 14)
	add_child(outer)

	var title := Label.new()
	title.text = "Choisis ton animal"
	title.add_theme_color_override("font_color", Color.WHITE)
	title.add_theme_font_size_override("font_size", 22)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	outer.add_child(title)

	# Zone défilable
	var scroll := ScrollContainer.new()
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	outer.add_child(scroll)

	var content := VBoxContainer.new()
	content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	content.add_theme_constant_override("separation", 20)
	scroll.add_child(content)

	for tier in [1, 2, 3, 4]:
		var section := _build_tier_section(tier)
		content.add_child(section)

func _build_tier_section(tier: int) -> VBoxContainer:
	var section := VBoxContainer.new()
	section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	section.add_theme_constant_override("separation", 8)

	# Titre du palier
	var tier_label := Label.new()
	tier_label.text = str(_tier_labels.get(tier, ""))
	var tc: Color = SpeciesDB.TIER_COLOR.get(tier, Color.WHITE)
	tier_label.add_theme_color_override("font_color", tc)
	tier_label.add_theme_font_size_override("font_size", 12)
	section.add_child(tier_label)

	# Rangée de cartes
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", 10)
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	section.add_child(hbox)

	var ids: Array = _tier_species.get(tier, [])
	for id_var in ids:
		var sid: String = str(id_var)
		var sp := SpeciesDB.get_species(sid)
		var locked := not GameManager.is_unlocked(sid)
		hbox.add_child(_make_card(sid, sp, locked))

	return section

func _make_card(species_id: String, sp: Dictionary, locked: bool) -> PanelContainer:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(110, 145)

	var style := StyleBoxFlat.new()
	if locked:
		style.bg_color     = Color(0.05, 0.05, 0.08, 1.0)
		style.border_color = Color(1, 1, 1, 0.10)
	else:
		var cls: String = str(sp.get("cls", "tank"))
		var cc: Color = SpeciesDB.CLASS_COLOR.get(cls, Color.WHITE)
		style.bg_color     = Color(cc.r * 0.15, cc.g * 0.15, cc.b * 0.15, 1.0)
		style.border_color = Color(cc.r, cc.g, cc.b, 0.55)
	style.border_width_left         = 2
	style.border_width_right        = 2
	style.border_width_top          = 2
	style.border_width_bottom       = 2
	style.corner_radius_top_left    = 14
	style.corner_radius_top_right   = 14
	style.corner_radius_bottom_right = 14
	style.corner_radius_bottom_left = 14
	card.add_theme_stylebox_override("panel", style)
	if locked:
		card.modulate.a = 0.45

	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_theme_constant_override("separation", 5)
	card.add_child(vbox)

	# Emoji ou cadenas
	var emoji_lbl := Label.new()
	emoji_lbl.text = "🔒" if locked else str(sp.get("emoji", "?"))
	emoji_lbl.add_theme_font_size_override("font_size", 34)
	emoji_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(emoji_lbl)

	# Nom
	var name_lbl := Label.new()
	name_lbl.text = str(sp.get("name", species_id))
	name_lbl.add_theme_color_override("font_color", Color.WHITE if not locked else Color(0.5, 0.5, 0.5))
	name_lbl.add_theme_font_size_override("font_size", 11)
	name_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	vbox.add_child(name_lbl)

	# Classe
	var cls_str: String = str(sp.get("cls", ""))
	var cls_lbl := Label.new()
	cls_lbl.text = cls_str.capitalize()
	var cls_color: Color = SpeciesDB.CLASS_COLOR.get(cls_str, Color.GRAY)
	cls_lbl.add_theme_color_override("font_color", cls_color if not locked else Color.GRAY)
	cls_lbl.add_theme_font_size_override("font_size", 9)
	cls_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vbox.add_child(cls_lbl)

	# Bouton invisible (uniquement si débloqué)
	if not locked:
		var btn := Button.new()
		btn.flat = true
		btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		btn.pressed.connect(_select.bind(species_id))
		card.add_child(btn)

	return card

func _select(species_id: String) -> void:
	species_selected.emit(species_id)
	queue_free()
