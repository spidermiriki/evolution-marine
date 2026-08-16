extends Node2D
class_name FoodItem

const WORLD_W := 3000.0
const WORLD_H := 3000.0

var move_angle: float = 0.0
var move_speed: float = 30.0
var turn_timer: float = 0.0
var radius: float = 5.0
var hue: float = 0.0

func setup() -> void:
	position = Vector2(randf() * WORLD_W, randf() * (WORLD_H - 50))
	move_angle = randf() * TAU
	move_speed = 30.0 + randf() * 40.0
	turn_timer = randf() * 3.0
	radius     = 4.0 + randf() * 2.0
	hue        = 40.0 + randf() * 160.0

func _process(delta: float) -> void:
	turn_timer -= delta
	if turn_timer <= 0.0:
		move_angle += (randf() - 0.5) * 1.5
		turn_timer = 1.0 + randf() * 2.5

	position += Vector2(cos(move_angle), sin(move_angle)) * move_speed * delta

	if position.x < radius or position.x > WORLD_W - radius:
		move_angle = PI - move_angle
	if position.y < radius or position.y > WORLD_H - radius:
		move_angle = -move_angle

	queue_redraw()

func _draw() -> void:
	var color := Color.from_hsv(hue / 360.0, 0.9, 0.65)
	# Corps elliptique
	var pts := PackedVector2Array()
	for i in range(16):
		var a := float(i) / 16.0 * TAU
		pts.append(Vector2(cos(a) * radius * 1.5, sin(a) * radius * 0.8))
	draw_colored_polygon(pts, color)
	# Queue
	draw_colored_polygon(PackedVector2Array([
		Vector2(-radius * 1.2, 0),
		Vector2(-radius * 2.2, -radius * 0.7),
		Vector2(-radius * 2.2,  radius * 0.7)
	]), color)
