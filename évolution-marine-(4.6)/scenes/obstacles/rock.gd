extends StaticBody2D
class_name Rock

var rock_radius: float = 30.0
var verts: PackedVector2Array = PackedVector2Array()

func setup(pos: Vector2) -> void:
	global_position = pos
	rock_radius = 26.0 + randf() * 30.0
	var sides := 7 + randi() % 3
	verts = PackedVector2Array()
	for i in range(sides):
		var ang := (float(i) / sides) * TAU
		var rad := rock_radius * (0.72 + randf() * 0.5)
		verts.append(Vector2(cos(ang) * rad, sin(ang) * rad))

	var poly := CollisionPolygon2D.new()
	poly.polygon = verts
	add_child(poly)
	set_collision_layer_value(2, true)

func _draw() -> void:
	draw_colored_polygon(verts, Color("444850"))
