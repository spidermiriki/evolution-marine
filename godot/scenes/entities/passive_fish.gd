extends CharacterBody2D
class_name PassiveFish

const WORLD_W := 3000.0
const WORLD_H := 3000.0

var fish_radius: float = 10.0
var hue: float = 0.0
var move_speed: float = 60.0
var move_angle: float = 0.0
var turn_timer: float = 0.0
var anim_tick: float = 0.0

var is_dead: bool = false
var eat_progress: float = 0.0
var eat_duration: float = 1.0

func setup() -> void:
	position    = Vector2(randf() * WORLD_W, randf() * (WORLD_H - 50))
	fish_radius = 10.0 + randf() * 4.0
	hue         = randf() * 360.0
	move_speed  = 50.0 + randf() * 50.0
	move_angle  = randf() * TAU
	turn_timer  = randf() * 3.0
	anim_tick   = randf() * 10.0

	var shape := CircleShape2D.new()
	shape.radius = fish_radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	collision_layer = 0   # invisible aux collisions physiques (pas de blocage joueur)
	collision_mask  = 2   # évite quand même les rochers/coraux (layer 2)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	turn_timer -= delta
	if turn_timer <= 0.0:
		move_angle += (randf() - 0.5) * 2.0
		turn_timer = 1.5 + randf() * 2.0

	anim_tick += delta * 10.0

	velocity = Vector2(cos(move_angle), sin(move_angle)) * move_speed
	move_and_slide()

	position.x = clamp(position.x, fish_radius, WORLD_W - fish_radius)
	position.y = clamp(position.y, fish_radius, WORLD_H - fish_radius)

	if position.x <= fish_radius or position.x >= WORLD_W - fish_radius:
		move_angle = PI - move_angle
	if position.y <= fish_radius or position.y >= WORLD_H - fish_radius:
		move_angle = -move_angle

	queue_redraw()

func _draw() -> void:
	var color := Color.from_hsv(hue / 360.0, 0.8, 0.6)
	var r := fish_radius
	var tail_wag := 0.0 if is_dead else sin(anim_tick * 2.0) * 3.0

	if is_dead:
		draw_set_transform(Vector2.ZERO, PI)

	# Queue
	draw_colored_polygon(PackedVector2Array([
		Vector2(-r, 0),
		Vector2(-r * 1.6, -r * 0.8 + tail_wag),
		Vector2(-r * 1.3, 0),
		Vector2(-r * 1.6,  r * 0.8 + tail_wag)
	]), color)

	# Corps
	var pts := PackedVector2Array()
	for i in range(32):
		var a := float(i) / 32.0 * TAU
		pts.append(Vector2(cos(a) * r, sin(a) * r * 0.5))
	draw_colored_polygon(pts, color)
	pts.append(pts[0])
	draw_polyline(pts, Color(0,0,0,0.2), 1.0)

	# Oeil
	draw_circle(Vector2(r * 0.5, -r * 0.15), r * 0.25, Color.WHITE)
	draw_circle(Vector2(r * 0.55, -r * 0.15), r * 0.1, Color.BLACK)

	if is_dead:
		draw_set_transform(Vector2.ZERO, 0.0)
