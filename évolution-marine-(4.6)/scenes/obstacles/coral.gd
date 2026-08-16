extends StaticBody2D
class_name Coral

const COLORS := [
	Color("ff6f91"), Color("ff9f68"), Color("c58bff"),
	Color("ff5da2"), Color("ffb86b"), Color("5be0c0")
]

var coral_radius: float = 14.0
var color: Color = Color.WHITE
var blobs: Array = []

func setup(pos: Vector2) -> void:
	global_position = pos
	coral_radius = 14.0 + randf() * 14.0
	color = COLORS[randi() % COLORS.size()]

	var nb := 4 + randi() % 3
	for _i in range(nb):
		var dx := (randf() - 0.5) * coral_radius * 1.5
		var dy := (randf() - 0.5) * coral_radius * 1.2 - coral_radius * 0.3
		var br := coral_radius * 0.4 + randf() * coral_radius * 0.3
		blobs.append({"dx": dx, "dy": dy, "r": br})

	var shape := CircleShape2D.new()
	shape.radius = coral_radius * 0.7
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	set_collision_layer_value(2, true)

func _draw() -> void:
	for b in blobs:
		draw_circle(Vector2(b.dx, b.dy), b.r, color)
