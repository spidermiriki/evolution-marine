extends Control
class_name MarineJoystick

signal direction_changed(vec: Vector2)

@export var base_radius: float = 55.0
@export var knob_radius: float = 23.0
@export var dead_zone:   float = 0.12

var direction: Vector2 = Vector2.ZERO
var _active: bool = false
var _touch_id: int = -1
var _origin: Vector2 = Vector2.ZERO

func _ready() -> void:
	# Positionné en bas à gauche
	anchor_left   = 0.0
	anchor_top    = 1.0
	anchor_right  = 0.0
	anchor_bottom = 1.0
	offset_left   = 36.0
	offset_top    = -(base_radius * 2.0 + 36.0)
	size          = Vector2(base_radius * 2.0, base_radius * 2.0)
	mouse_filter  = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)

func _screen_to_local(screen_pos: Vector2) -> Vector2:
	return screen_pos - global_position

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		var touch := event as InputEventScreenTouch
		if touch.pressed:
			var rect := Rect2(global_position, size)
			if rect.has_point(touch.position) and not _active:
				_active = true
				_touch_id = touch.index
				_origin = Vector2(base_radius, base_radius)
				_update_direction(_screen_to_local(touch.position))
		else:
			if touch.index == _touch_id:
				_release()

	elif event is InputEventScreenDrag:
		var drag := event as InputEventScreenDrag
		if drag.index == _touch_id and _active:
			_update_direction(_screen_to_local(drag.position))

	elif event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			var rect := Rect2(global_position, size)
			if mb.pressed and rect.has_point(mb.global_position) and not _active:
				_active = true
				_touch_id = -2
				_origin = Vector2(base_radius, base_radius)
				_update_direction(_screen_to_local(mb.global_position))
			elif not mb.pressed and _touch_id == -2:
				_release()

	elif event is InputEventMouseMotion:
		if _active and _touch_id == -2:
			_update_direction(_screen_to_local((event as InputEventMouseMotion).global_position))

func _update_direction(local_pos: Vector2) -> void:
	var delta := local_pos - _origin
	var len   := delta.length()
	var max_r := base_radius - knob_radius
	if len > max_r:
		delta = delta.normalized() * max_r
	direction = delta / max_r if len > dead_zone * max_r else Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func _release() -> void:
	_active   = false
	_touch_id = -1
	direction = Vector2.ZERO
	direction_changed.emit(direction)
	queue_redraw()

func _draw() -> void:
	# Base
	draw_circle(Vector2(base_radius, base_radius), base_radius,
		Color(1, 1, 1, 0.08))
	var pts: PackedVector2Array = []
	for i in range(33):
		var a := float(i) / 32.0 * TAU
		pts.append(Vector2(base_radius, base_radius) +
			Vector2(cos(a), sin(a)) * base_radius)
	draw_polyline(pts, Color(1, 1, 1, 0.25), 2.0, true)

	# Knob
	var max_r := base_radius - knob_radius
	var knob_pos := Vector2(base_radius, base_radius) + direction * max_r
	draw_circle(knob_pos, knob_radius, Color(1, 1, 1, 0.35))
	var kpts: PackedVector2Array = []
	for i in range(33):
		var a := float(i) / 32.0 * TAU
		kpts.append(knob_pos + Vector2(cos(a), sin(a)) * knob_radius)
	draw_polyline(kpts, Color(1, 1, 1, 0.6), 2.0, true)
