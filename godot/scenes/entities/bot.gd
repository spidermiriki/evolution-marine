extends CharacterBody2D
class_name Bot

const WORLD_W := 3000.0
const WORLD_H := 3000.0
const CENTER  := Vector2(1500, 1500)

var species_id: String = "crabe"
var bot_scale: float = 1.0
var bot_radius: float = 22.0

var hp: float = 100.0
var max_hp: float = 100.0
var is_dead: bool = false
var eat_progress: float = 0.0
var eat_duration: float = 1.5

var state: String = "wander"
var move_angle: float = 0.0
var wander_timer: float = 0.0
var attack_cooldown: float = 0.0
var anim_tick: float = 0.0

var _renderer: SpeciesRenderer = null
var _hp_bar: Node2D = null

func setup(sid: String) -> void:
	species_id = sid
	var sp := SpeciesDB.get_species(sid)
	bot_radius = sp.get("radius", 20.0) * bot_scale
	max_hp = sp.get("max_hp", 100.0)
	hp = max_hp
	eat_duration = 1.0 + float(sp.get("tier", 1)) * 0.4
	move_angle = randf() * TAU
	wander_timer = randf() * 2.0
	anim_tick = randf() * 10.0

	# Collision
	var shape := CircleShape2D.new()
	shape.radius = bot_radius
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)
	collision_layer = 0   # invisible aux collisions physiques (pas de blocage joueur)
	collision_mask  = 2   # évite quand même les rochers/coraux (layer 2)

	# Renderer visuel
	_renderer = SpeciesRenderer.new()
	_renderer.species_id = species_id
	_renderer.entity_scale = bot_scale
	add_child(_renderer)

func _physics_process(delta: float) -> void:
	if is_dead:
		return

	if attack_cooldown > 0.0:
		attack_cooldown -= delta

	var sp := SpeciesDB.get_species(species_id)
	var bot_speed: float = float(sp.get("speed", 100.0)) * 0.7

	# Trouver la cible la plus proche (joueur ou autre bot vivant)
	var best_target: Node2D = null
	var best_dist := INF
	var best_radius := 0.0

	var player := GameManager.player
	if player != null and not player.is_camouflaged and not player.is_evolving:
		var d := global_position.distance_to(player.global_position)
		if d < 350.0:
			best_target = player
			best_dist   = d
			best_radius = float(SpeciesDB.get_species(player.species_id).get("radius", 20.0))

	if GameManager.world != null:
		for other in GameManager.world.bots:
			if other == null or other == self or other.is_dead:
				continue
			var d := global_position.distance_to(other.global_position)
			if d < 300.0 and d < best_dist:
				best_target = other
				best_dist   = d
				best_radius = other.bot_radius

	# Décider état selon taille relative
	if best_target != null:
		state = "chase" if (bot_radius >= best_radius * 0.9) else "flee"
	else:
		state = "wander"

	match state:
		"flee":
			var away := global_position - best_target.global_position
			move_angle = atan2(away.y, away.x)
			bot_speed *= 1.3
		"chase":
			var toward := best_target.global_position - global_position
			move_angle = atan2(toward.y, toward.x)
			bot_speed *= 1.25
		"wander":
			wander_timer -= delta
			if wander_timer <= 0.0:
				move_angle += (randf() - 0.5) * 2.4
				wander_timer = 1.5 + randf() * 2.0

	anim_tick += delta * 8.0
	velocity = Vector2(cos(move_angle), sin(move_angle)) * bot_speed
	move_and_slide()

	global_position.x = clamp(global_position.x, bot_radius, WORLD_W - bot_radius)
	global_position.y = clamp(global_position.y, bot_radius, WORLD_H - bot_radius)

	# Orienter le renderer
	var norm_angle := fmod(move_angle, TAU)
	if norm_angle > PI / 2.0 or norm_angle < -PI / 2.0:
		_renderer.scale.y = -1.0
	else:
		_renderer.scale.y = 1.0
	_renderer.rotation = move_angle
	_renderer.anim_tick = anim_tick
	_renderer.queue_redraw()

	# Attaque au contact si la cible est à portée
	if best_target != null and best_dist < best_radius + bot_radius + 8.0 and attack_cooldown <= 0.0:
		if bot_radius >= best_radius * 0.75:
			var dmg: float = 15.0 + float(sp.get("tier", 1)) * 8.0
			if best_target is Player:
				if not (best_target as Player).is_camouflaged:
					best_target.take_damage(dmg)
					attack_cooldown = 0.8
			elif best_target is Bot:
				(best_target as Bot).hp -= dmg
				if (best_target as Bot).hp <= 0.0:
					(best_target as Bot).hp = 0.0
					(best_target as Bot).is_dead = true
				attack_cooldown = 0.8

func _draw() -> void:
	# Barre de vie au-dessus
	if not is_dead and hp < max_hp:
		var bar_w := 36.0
		var bar_h := 5.0
		var y_off := -(bot_radius + 12.0)
		draw_rect(Rect2(-bar_w/2, y_off, bar_w, bar_h), Color(0,0,0,0.5))
		draw_rect(Rect2(-bar_w/2, y_off, bar_w * (hp/max_hp), bar_h), Color("ff4d4d"))

	if is_dead and eat_progress > 0.0:
		var bar_w := 40.0
		var bar_h := 6.0
		var y_off := -(bot_radius + 16.0)
		draw_rect(Rect2(-bar_w/2, y_off, bar_w, bar_h), Color(0,0,0,0.5))
		draw_rect(Rect2(-bar_w/2, y_off, bar_w * (eat_progress/eat_duration), bar_h), Color("5fd1ff"))
