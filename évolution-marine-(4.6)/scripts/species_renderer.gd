extends Node2D
class_name SpeciesRenderer

@export var species_id: String = "crabe"
var anim_tick: float = 0.0
var claw_anim: float = 0.0
var is_dead: bool = false
var entity_scale: float = 1.0

func _draw() -> void:
	draw_set_transform(Vector2.ZERO, 0.0, Vector2(entity_scale, entity_scale))
	match species_id:
		"crabe":         _draw_crab()
		"sole":          _draw_sole()
		"aiguille":      _draw_needlefish()
		"poisson_globe": _draw_pufferfish()
		"raie":          _draw_ray()
		"baliste":       _draw_triggerfish()
		"murene":        _draw_moray()
		"bonite":        _draw_bonito()
		"merou_geant":   _draw_grouper()
		"wobbegong":     _draw_wobbegong()
		"barracuda":     _draw_barracuda()
		_:
			draw_circle(Vector2.ZERO, 12.0, Color.WHITE)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Helpers ---

func _ellipse_points(cx: float, cy: float, rx: float, ry: float,
		rot: float = 0.0, n: int = 32) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(n):
		var a := float(i) / n * TAU
		var p := Vector2(cos(a) * rx, sin(a) * ry).rotated(rot)
		pts.append(Vector2(cx, cy) + p)
	return pts

func _fill_ellipse(cx: float, cy: float, rx: float, ry: float,
		color: Color, rot: float = 0.0) -> void:
	draw_colored_polygon(_ellipse_points(cx, cy, rx, ry, rot), color)

func _stroke_ellipse(cx: float, cy: float, rx: float, ry: float,
		color: Color, w: float = 1.5, rot: float = 0.0) -> void:
	var pts := _ellipse_points(cx, cy, rx, ry, rot)
	pts.append(pts[0])
	draw_polyline(pts, color, w, true)

func _half_ellipse_points(cx: float, cy: float, rx: float, ry: float,
		offset_y: float = 0.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in range(17):
		var a := float(i) / 16.0 * PI
		pts.append(Vector2(cx + cos(a) * rx, cy + sin(a) * ry + offset_y))
	return pts

# --- Crabe ---

func _draw_crab() -> void:
	var body  := Color("e63946")
	var shell := Color("b7094c")
	var acc   := Color("ff6b6b")
	var leg_o := sin(anim_tick) * 5.0

	for s in [-1, 1]:
		draw_line(Vector2(s*6, -4), Vector2(s*20, -14 + leg_o*s), shell, 3.5, true)
		draw_line(Vector2(s*20, -14 + leg_o*s), Vector2(s*26, -4), shell, 3.5, true)
		draw_line(Vector2(s*6,  4), Vector2(s*20,  14 - leg_o*s), shell, 3.5, true)
		draw_line(Vector2(s*20,  14 - leg_o*s), Vector2(s*26,  4), shell, 3.5, true)

	_fill_ellipse(0, 0, 16, 12, body)
	_stroke_ellipse(0, 0, 16, 12, shell, 2.0)
	_fill_ellipse(-3, -4, 6, 3, Color(acc.r, acc.g, acc.b, 0.6), -0.2)

	draw_circle(Vector2(8, -6), 2.5, shell)
	draw_circle(Vector2(8,  6), 2.5, shell)
	draw_circle(Vector2(9, -6), 1.0, Color.WHITE)
	draw_circle(Vector2(9,  6), 1.0, Color.WHITE)

	var open_ang := 0.8 if claw_anim > 0 else 0.2
	draw_set_transform(Vector2(10, -10), -open_ang, Vector2.ONE)
	draw_circle(Vector2(0, -4), 6, body)
	_stroke_ellipse(0, -4, 6, 6, shell, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	draw_set_transform(Vector2(10, 10), open_ang, Vector2.ONE)
	draw_circle(Vector2(0, 4), 6, body)
	_stroke_ellipse(0, 4, 6, 6, shell, 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Raie ---

func _draw_ray() -> void:
	var top  := Color("c2b29b")
	var dark := Color("9c8c74")
	var ww1  := sin(anim_tick * 2) * 5.0
	var ww2  := sin(anim_tick * 2 + 1.2) * 6.0
	var tail := sin(anim_tick * 3) * 4.0

	draw_line(Vector2(-10, 0), Vector2(-22, tail),     dark, 2.0, true)
	draw_line(Vector2(-22, tail), Vector2(-35, tail*1.5), dark, 2.0, true)

	var wing := PackedVector2Array([
		Vector2(16, 0),
		Vector2(4,  -14 + ww1),
		Vector2(-12, -22 + ww2),
		Vector2(-16, -6),
		Vector2(-10, 0),
		Vector2(-12,  22 - ww2),
		Vector2(4,   14 - ww1),
	])
	draw_colored_polygon(wing, top)
	wing.append(wing[0])
	draw_polyline(wing, dark, 1.5, true)

	_fill_ellipse(2, 0, 10, 7, Color("b5a38a"))
	_stroke_ellipse(2, 0, 10, 7, dark, 1.5)

	draw_circle(Vector2(8, -4), 1.5, Color("4a3f35"))
	draw_circle(Vector2(8,  4), 1.5, Color("4a3f35"))

# --- Poisson-Aiguille ---

func _draw_needlefish() -> void:
	var body   := Color("00b4d8")
	var belly  := Color("ade8f4")
	var beak   := Color("90e0ef")
	var stripe := Color("0077b6")
	var tail   := sin(anim_tick * 1.5) * 4.0

	draw_colored_polygon(PackedVector2Array([
		Vector2(-14, 0), Vector2(-24, -8+tail),
		Vector2(-20, 0), Vector2(-24,  8+tail)
	]), body)

	_fill_ellipse(0, 0, 16, 6, body)
	_stroke_ellipse(0, 0, 16, 6, stripe, 2.0)
	draw_colored_polygon(_half_ellipse_points(0, 2, 12, 3.5), belly)

	draw_colored_polygon(PackedVector2Array([
		Vector2(14,-2), Vector2(26,-0.5), Vector2(26,0.5), Vector2(14,2)
	]), beak)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-4,-6), Vector2(2,-10), Vector2(8,-5)
	]), body)

	draw_circle(Vector2(10, -2), 2.0, Color("03045e"))
	draw_circle(Vector2(10.5, -2.5), 0.7, Color.WHITE)

# --- Baliste ---

func _draw_triggerfish() -> void:
	var body  := Color("ff6b35")
	var dark  := Color("c44d1a")
	var acc   := Color("ffdd57")
	var tail  := sin(anim_tick * 2) * 5.0

	draw_colored_polygon(PackedVector2Array([
		Vector2(-18,0), Vector2(-30,-10+tail),
		Vector2(-24,0), Vector2(-30, 10+tail)
	]), body)

	_fill_ellipse(0, 0, 22, 14, body)
	_stroke_ellipse(0, 0, 22, 14, dark, 2.5)
	draw_line(Vector2(-5,-14), Vector2(-5, 14), acc, 3.0)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-8,-14), Vector2(4,-24), Vector2(12,-13)
	]), dark)

	draw_circle(Vector2(12, -4), 3.0, Color.WHITE)
	draw_circle(Vector2(12.5, -4), 1.5, Color.BLACK)
	draw_line(Vector2(0,-14), Vector2(0,-20), acc, 2.0)

# --- Bonite ---

func _draw_bonito() -> void:
	var back   := Color("1d3557")
	var belly  := Color("f1faee")
	var stripe := Color("457b9d")
	var fin    := Color("e63946")
	var tail   := sin(anim_tick * 2) * 6.0

	draw_colored_polygon(PackedVector2Array([
		Vector2(-16,0), Vector2(-28,-12+tail),
		Vector2(-22,0), Vector2(-28, 12+tail)
	]), back)

	_fill_ellipse(0, 0, 18, 8, back)
	_stroke_ellipse(0, 0, 18, 8, Color("14213d"), 2.0)
	draw_colored_polygon(_half_ellipse_points(0, 3, 14, 4.5), belly)

	draw_line(Vector2(-6,-6), Vector2(-2,-2), stripe, 2.0)
	draw_line(Vector2(-1,-7), Vector2(3,-2),  stripe, 2.0)
	draw_line(Vector2(4,-6),  Vector2(8,-2),  stripe, 2.0)

	draw_colored_polygon(PackedVector2Array([
		Vector2(-6,-8), Vector2(2,-15), Vector2(8,-7)
	]), fin)
	draw_colored_polygon(PackedVector2Array([
		Vector2(2,2), Vector2(8,10), Vector2(12,4)
	]), stripe)

	draw_circle(Vector2(11, -2), 2.2, Color("0f172a"))
	draw_circle(Vector2(11.5, -2.5), 0.8, Color.WHITE)

# --- Murène ---

func _draw_moray() -> void:
	var skin  := Color("588157")
	var spots := Color("3a5a40")
	var belly := Color("a3b18a")

	for i in range(6, 0, -1):
		var prog := float(i) / 6.0
		var wave := sin(anim_tick * 1.5 - i * 0.6) * (6.0 * (1.0 - prog))
		var sr   := 10.0 * (1.0 - prog * 0.5)
		var col  := skin if i % 2 == 0 else belly
		_fill_ellipse(-i * 5, wave, sr, sr * 0.75, col)
		_stroke_ellipse(-i * 5, wave, sr, sr * 0.75, spots, 1.5)

	draw_set_transform(Vector2(6, 0), 0.0, Vector2.ONE)
	_fill_ellipse(0, 0, 10, 8, skin)
	_stroke_ellipse(0, 0, 10, 8, spots, 2.0)
	draw_circle(Vector2(3, -4), 2.0, Color("ffb703"))
	draw_circle(Vector2(3,  4), 2.0, Color("ffb703"))
	draw_circle(Vector2(3.5,-4), 0.8, Color.BLACK)
	draw_circle(Vector2(3.5, 4), 0.8, Color.BLACK)
	draw_line(Vector2(6,-3), Vector2(12,-1), Color("283618"), 2.0)
	draw_line(Vector2(6, 3), Vector2(12, 1), Color("283618"), 2.0)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

# --- Sole (furtif P1) ---

func _draw_sole() -> void:
	var body  := Color("c8a97e")
	var dark  := Color("8b6448")
	var wave  := sin(anim_tick * 1.2) * 2.0

	# Queue ondulante
	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, wave), Vector2(-28, -5 + wave),
		Vector2(-23, 0),    Vector2(-28,  5 + wave)
	]), body)

	# Corps plat (ovale large)
	_fill_ellipse(0, 0, 20, 10, body, 0.08)
	_stroke_ellipse(0, 0, 20, 10, dark, 1.5, 0.08)

	# Taches de camouflage
	draw_circle(Vector2(-7, -2 + wave * 0.2), 2.5, dark)
	draw_circle(Vector2(2,  -3 + wave * 0.2), 2.0, dark)
	draw_circle(Vector2(9,   1 + wave * 0.2), 1.8, dark)

	# Deux yeux du même côté (dessus)
	draw_circle(Vector2(10, -5), 2.5, Color("3a2010"))
	draw_circle(Vector2(10.6, -5.6), 0.9, Color.WHITE)
	draw_circle(Vector2(13, -3), 2.0, Color("3a2010"))
	draw_circle(Vector2(13.6, -3.6), 0.7, Color.WHITE)

	# Nageoire dorsale (ligne)
	draw_line(Vector2(-12, -8 + wave * 0.3), Vector2(10, -9 + wave * 0.1), dark, 1.5, true)

# --- Poisson-globe (tank P2) ---

func _draw_pufferfish() -> void:
	var body  := Color("e8c547")
	var dark  := Color("b8920a")
	var spine := Color("7a6010")
	var tail  := sin(anim_tick * 2.0) * 4.0

	# Queue
	draw_colored_polygon(PackedVector2Array([
		Vector2(-18, 0), Vector2(-28, -8 + tail),
		Vector2(-22, 0), Vector2(-28,  8 + tail)
	]), body)

	# Corps rond
	_fill_ellipse(0, 0, 20, 18, body)
	_stroke_ellipse(0, 0, 20, 18, dark, 2.0)

	# Ventre clair
	draw_colored_polygon(_half_ellipse_points(0, 4, 14, 8), Color("f5e88a"))

	# Épines
	for i in range(12):
		var a := float(i) / 12.0 * TAU
		var inner := Vector2(cos(a) * 18.0, sin(a) * 16.0)
		var outer := Vector2(cos(a) * 25.0, sin(a) * 23.0)
		draw_line(inner, outer, spine, 2.0)

	# Œil
	draw_circle(Vector2(14, -4), 3.5, Color.WHITE)
	draw_circle(Vector2(14, -4), 2.0, Color("100800"))
	draw_circle(Vector2(14.6, -4.6), 0.7, Color.WHITE)

	# Bouche
	draw_line(Vector2(17, 2), Vector2(21, 3), dark, 2.0)

# --- Lotte / poisson-pêcheur (furtif P2) ---

func _draw_anglerfish() -> void:
	var body  := Color("2d3a2a")
	var dark  := Color("1a221a")
	var belly := Color("3e5038")
	var tooth := Color("d4c9a0")
	var glow  := Color("00ff88")
	var tail  := sin(anim_tick * 1.5) * 4.0

	# Queue
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16, 0), Vector2(-28, -6 + tail),
		Vector2(-22, 0), Vector2(-28,  6 + tail)
	]), body)

	# Corps (grosse tête ronde)
	_fill_ellipse(2, 0, 18, 14, body)
	_stroke_ellipse(2, 0, 18, 14, dark, 2.0)
	draw_colored_polygon(_half_ellipse_points(2, 2, 14, 8), belly)

	# Grande gueule
	draw_line(Vector2(14, -2), Vector2(22, 3), dark, 3.0)
	draw_line(Vector2(14,  4), Vector2(22, 3), belly, 2.5)
	for i in range(4):
		draw_line(Vector2(15.0 + float(i) * 2.0, 0.0),
				  Vector2(15.5 + float(i) * 2.0, 4.5), tooth, 1.5)

	# Grand œil (poisson des profondeurs)
	draw_circle(Vector2(6, -6), 5.0, Color(0, 0, 0, 0.3))
	draw_circle(Vector2(6, -6), 4.0, Color("90c0f0"))
	draw_circle(Vector2(6, -6), 2.5, Color.BLACK)
	draw_circle(Vector2(7, -7), 0.8, Color.WHITE)

	# Leurre bioluminescent
	draw_line(Vector2(8, -12), Vector2(18, -24), dark, 2.0)
	var pulse := 0.6 + sin(anim_tick * 3.0) * 0.4
	draw_circle(Vector2(18, -24), 5.0, Color(glow.r, glow.g, glow.b, pulse * 0.3))
	draw_circle(Vector2(18, -24), 2.5, Color(glow.r, glow.g, glow.b, pulse))

# --- Maquereau (rapide P2) ---

func _draw_mackerel() -> void:
	var back   := Color("2d7a8e")
	var belly  := Color("e0f0f5")
	var stripe := Color("1a4a5c")
	var fin    := Color("3a9ab2")
	var tail   := sin(anim_tick * 2.5) * 7.0

	# Queue bifurquée
	draw_colored_polygon(PackedVector2Array([
		Vector2(-16, 0), Vector2(-28, -9 + tail),
		Vector2(-20, 0), Vector2(-28,  9 + tail)
	]), back)

	# Corps fuselé
	_fill_ellipse(0, 0, 18, 7, back)
	_fill_ellipse(2, 1, 14, 4.5, belly)
	_stroke_ellipse(0, 0, 18, 7, stripe, 1.5)

	# Rayures ondulées sur le dos
	for i in range(5):
		var sx := -8.0 + float(i) * 5.0
		var sy := sin(anim_tick * 2.5 + float(i) * 0.8) * 1.0 - 4.0
		draw_circle(Vector2(sx, sy), 1.2, stripe)

	# Nageoire dorsale
	draw_colored_polygon(PackedVector2Array([
		Vector2(-4, -7), Vector2(4, -13), Vector2(10, -7)
	]), fin)

	# Œil
	draw_circle(Vector2(12, -2), 2.5, Color.WHITE)
	draw_circle(Vector2(12, -2), 1.4, Color("040e18"))
	draw_circle(Vector2(12.5, -2.5), 0.5, Color.WHITE)

	# Museau
	draw_line(Vector2(16, -1), Vector2(22, 0), belly, 2.0)

# --- Mérou géant (tank P4) ---

func _draw_grouper() -> void:
	var body  := Color("6b4e2a")
	var dark  := Color("3d2a10")
	var spot  := Color("28180a")
	var belly := Color("b8896a")
	var tail  := sin(anim_tick * 1.8) * 6.0

	# Queue
	draw_colored_polygon(PackedVector2Array([
		Vector2(-28, 0), Vector2(-44, -14 + tail),
		Vector2(-36, 0), Vector2(-44,  14 + tail)
	]), body)

	# Grand corps arrondi
	_fill_ellipse(0, 0, 30, 22, body)
	_stroke_ellipse(0, 0, 30, 22, dark, 3.0)
	draw_colored_polygon(_half_ellipse_points(0, 4, 22, 12), belly)

	# Taches
	draw_circle(Vector2(-15, -8),  4.0, spot)
	draw_circle(Vector2(-5,  -14), 3.5, spot)
	draw_circle(Vector2(8,   -10), 4.0, spot)
	draw_circle(Vector2(-18,  4),  3.0, spot)
	draw_circle(Vector2(0,    5),  4.5, spot)
	draw_circle(Vector2(15,  -4),  3.0, spot)

	# Grande bouche
	draw_colored_polygon(PackedVector2Array([
		Vector2(18, -6), Vector2(32, -2), Vector2(32, 4), Vector2(18, 8)
	]), dark)
	draw_line(Vector2(18, -6), Vector2(32, -2), belly, 1.5)

	# Œil
	draw_circle(Vector2(16, -12), 5.0, Color.WHITE)
	draw_circle(Vector2(16, -12), 3.0, Color("120800"))
	draw_circle(Vector2(17, -13), 1.0, Color.WHITE)

# --- Wobbegong / requin-tapis (furtif P4) ---

func _draw_wobbegong() -> void:
	var body  := Color("8b7355")
	var dark  := Color("5c4a2a")
	var light := Color("c4a97a")
	var wave  := sin(anim_tick * 1.0) * 2.0

	# Queue
	draw_colored_polygon(PackedVector2Array([
		Vector2(-26, 0), Vector2(-38, -8 + wave),
		Vector2(-32, 0), Vector2(-38,  8 + wave)
	]), body)

	# Corps plat et large
	_fill_ellipse(0, 0, 28, 14, body)
	_stroke_ellipse(0, 0, 28, 14, dark, 2.0)

	# Motif camouflage
	_fill_ellipse(-12, -3, 8, 5, dark)
	_fill_ellipse(2,   -5, 7, 4, dark)
	_fill_ellipse(14,  -2, 6, 4, dark)
	_fill_ellipse(-6,   4, 9, 5, light)
	_fill_ellipse(8,    5, 7, 4, light)
	_fill_ellipse(-18,  2, 5, 3, light)

	# Franges (tassels) sur les bords
	for i in range(8):
		var tx := -24.0 + float(i) * 7.0
		var fringe := sin(anim_tick * 1.5 + float(i) * 0.9) * 2.0
		draw_line(Vector2(tx, -10), Vector2(tx, -15 + fringe), dark, 2.0)
		draw_line(Vector2(tx,  10), Vector2(tx,  15 - fringe), dark, 2.0)

	# Tête et yeux
	_fill_ellipse(22, 0, 8, 8, body)
	_stroke_ellipse(22, 0, 8, 8, dark, 1.5)
	draw_circle(Vector2(24, -4), 3.0, Color("1e1200"))
	draw_circle(Vector2(24.5, -4.5), 1.0, Color.WHITE)
	draw_circle(Vector2(24,  4), 3.0, Color("1e1200"))
	draw_circle(Vector2(24.5,  4.5), 1.0, Color.WHITE)

# --- Barracuda (rapide P4) ---

func _draw_barracuda() -> void:
	var back   := Color("1a3a4a")
	var belly  := Color("c8d8e0")
	var stripe := Color("2a5a72")
	var jaw    := Color("d0d0c8")
	var tail   := sin(anim_tick * 3.0) * 8.0

	# Queue puissante bifurquée
	draw_colored_polygon(PackedVector2Array([
		Vector2(-20, 0), Vector2(-36, -12 + tail),
		Vector2(-26, 0), Vector2(-36,  12 + tail)
	]), back)

	# Corps torpille
	_fill_ellipse(0, 0, 22, 7, back)
	draw_colored_polygon(_half_ellipse_points(0, 3, 18, 4), belly)
	_stroke_ellipse(0, 0, 22, 7, stripe, 1.5)

	# Ligne argentée latérale
	draw_line(Vector2(-18, 0), Vector2(18, 0), Color(belly.r, belly.g, belly.b, 0.5), 2.5)

	# Nageoire dorsale en lame
	draw_colored_polygon(PackedVector2Array([
		Vector2(-8, -7), Vector2(0, -16), Vector2(10, -8)
	]), stripe)

	# Mâchoire pointue avec dents
	draw_colored_polygon(PackedVector2Array([
		Vector2(16, -3), Vector2(32, -1), Vector2(32, 1), Vector2(16, 3)
	]), belly)
	draw_colored_polygon(PackedVector2Array([
		Vector2(16, -2), Vector2(32, -1), Vector2(16, 2)
	]), back)
	for i in range(4):
		draw_line(Vector2(18.0 + float(i) * 3.5, -2.0),
				  Vector2(18.5 + float(i) * 3.5,  1.5), jaw, 1.5)

	# Œil prédateur
	draw_circle(Vector2(12, -2), 3.0, Color.WHITE)
	draw_circle(Vector2(12, -2), 2.0, Color("080810"))
	draw_circle(Vector2(12.5, -2.5), 0.7, Color.WHITE)
