extends CharacterBody2D
class_name Player

const WORLD_W := 3000.0
const WORLD_H := 3000.0

# Espèce
var species_id: String = "crabe"

# Stats
var xp: float = 0.0
var hp: float = 100.0
var max_hp: float = 100.0
var stamina: float = 100.0
var invuln: float = 0.0
var is_camouflaged: bool = false
var stealth_cooldown: float = 0.0

# Attaque
var claw_cooldown: float = 0.0
var claw_anim: float = 0.0
var bite_cooldown: float = 0.0
var facing_angle: float = 0.0
var anim_tick: float = 0.0

# Evolution
var is_evolving: bool = false
var evolve_timer: float = 0.0
var evolve_duration: float = 1.0
var evolve_target_id: String = ""

# Boost épuisé (comme Zelda : verrouillé jusqu'à seuil de récupération)
var boost_exhausted: bool = false
const BOOST_RECOVER_THRESHOLD := 35.0   # % stamina pour pouvoir rebooster

# Poisson-ballon : gonflement défensif
var is_puffed: bool = false
var puff_timer: float = 0.0
var puff_cooldown: float = 0.0
const PUFF_DURATION  := 4.5
const PUFF_COOLDOWN  := 20.0

# Références
var _renderer: SpeciesRenderer = null
var _camera: Camera2D = null
var joystick_vec: Vector2 = Vector2.ZERO
var boost_active: bool = false
var aiming: bool = false
var manual_aim_angle: float = 0.0
var has_manual_aim: bool = false

func _ready() -> void:
	GameManager.player = self
	_setup_collision()
	_setup_renderer()
	_setup_camera()
	collision_layer = 1   # layer 1 uniquement (joueur)
	collision_mask  = 2   # collide avec obstacles (layer 2) uniquement

func _setup_collision() -> void:
	var shape := CircleShape2D.new()
	shape.radius = _get_radius()
	var col := CollisionShape2D.new()
	col.shape = shape
	add_child(col)

func _setup_renderer() -> void:
	_renderer = SpeciesRenderer.new()
	_renderer.species_id = species_id
	add_child(_renderer)

func _setup_camera() -> void:
	_camera = Camera2D.new()
	_camera.position_smoothing_enabled = true
	_camera.position_smoothing_speed = 6.0
	_camera.zoom = Vector2(1.5, 1.5)
	add_child(_camera)

func _get_radius() -> float:
	return SpeciesDB.get_species(species_id).get("radius", 20.0)

func get_radius() -> float:
	return _get_radius()

# --- Changement d'espèce ---

func change_species(new_id: String) -> void:
	species_id = new_id
	var sp := SpeciesDB.get_species(new_id)
	max_hp = sp.get("max_hp", 100.0)
	hp = max_hp
	is_puffed = false
	puff_timer = 0.0
	puff_cooldown = 0.0
	boost_exhausted = false
	_renderer.species_id = new_id

	# Mettre à jour la collision
	for child in get_children():
		if child is CollisionShape2D:
			(child.shape as CircleShape2D).radius = sp.get("radius", 20.0)

	GameManager.species_changed.emit(new_id)
	GameManager.hp_changed.emit(int(hp), int(max_hp))
	GameManager.xp_changed.emit(0, int(sp.get("xp_to_evolve", 80)))

# --- Physique ---

func _physics_process(delta: float) -> void:
	if is_evolving:
		evolve_timer += delta
		if evolve_timer >= evolve_duration:
			_finish_evolve()
		return

	_update_timers(delta)
	_update_camouflage()
	_handle_movement(delta)
	_check_world_bounds()
	_update_renderer()
	queue_redraw()

func _input(event: InputEvent) -> void:
	# Clic gauche = attaque pince/dard (PC), vise vers le curseur
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT:
			var aim := global_position.direction_to(get_global_mouse_position()).angle()
			trigger_claw_attack(aim)

func _update_timers(delta: float) -> void:
	if claw_cooldown > 0.0: claw_cooldown -= delta
	if claw_anim     > 0.0: claw_anim     -= delta
	if bite_cooldown > 0.0: bite_cooldown -= delta
	if stealth_cooldown > 0.0: stealth_cooldown -= delta
	if invuln > 0.0: invuln -= delta
	# Gonflement poisson-ballon
	if puff_timer > 0.0:
		puff_timer -= delta
		if puff_timer <= 0.0:
			is_puffed = false
			puff_cooldown = PUFF_COOLDOWN
	if puff_cooldown > 0.0:
		puff_cooldown -= delta

func _update_camouflage() -> void:
	var sp := SpeciesDB.get_species(species_id)
	if str(sp.get("cls", "")) != "furtif":
		is_camouflaged = false
		return
	match species_id:
		"sole", "raie", "lotte", "wobbegong":
			# Camouflage au fond sableux
			is_camouflaged = (global_position.y >= WORLD_H - _get_radius() - 30.0) \
				and stealth_cooldown <= 0.0
		"murene":
			var near_rock := _is_near_rock()
			is_camouflaged = near_rock and stealth_cooldown <= 0.0
		_:
			is_camouflaged = false

func _is_near_rock() -> bool:
	if GameManager.world == null:
		return false
	for rock in GameManager.world.rocks:
		if rock == null:
			continue
		if global_position.distance_to(rock.global_position) < rock.rock_radius + _get_radius() + 15.0:
			return true
	return false

func _handle_movement(delta: float) -> void:
	var sp := SpeciesDB.get_species(species_id)
	var dir := joystick_vec

	var mouse_world := get_global_mouse_position()
	var to_mouse   := global_position.direction_to(mouse_world)
	var dist_mouse := global_position.distance_to(mouse_world)

	if dir.length() < 0.1:
		# --- PC : l'animal nage vers le curseur ---
		facing_angle = to_mouse.angle()
		if dist_mouse > 12.0:
			dir = to_mouse
	else:
		# --- Mobile : joystick ---
		facing_angle = dir.angle()

	# --- Boost : Shift / Espace (PC) ou bouton HUD (mobile) ---
	var kb_boost := Input.is_key_pressed(KEY_SHIFT) or Input.is_key_pressed(KEY_SPACE)
	var effective_boost := boost_active or kb_boost

	# Boost casse le camouflage pour murène et raie
	if effective_boost and is_camouflaged and species_id in ["murene", "raie"]:
		stealth_cooldown = 3.0
		is_camouflaged = false

	if dir.length() > 0.01:
		anim_tick += delta * 12.0

	var move_speed := float(sp.get("speed", 140.0))
	# Réduction de vitesse si gonflé (poisson-ballon)
	if is_puffed:
		move_speed *= 0.6

	var drain := float(sp.get("stamina_drain", 55.0))

	# Épuisement : boost verrouillé jusqu'au seuil de récupération
	if stamina <= 0.0:
		boost_exhausted = true
	if boost_exhausted and stamina >= BOOST_RECOVER_THRESHOLD:
		boost_exhausted = false

	var can_boost := effective_boost and stamina > 0.0 and not boost_exhausted
	if can_boost:
		move_speed *= 1.8
		stamina = max(0.0, stamina - delta * drain)
	else:
		stamina = min(100.0, stamina + delta * 18.0)

	GameManager.stamina_changed.emit(stamina)

	if dir.length() > 0.01:
		velocity = dir.normalized() * move_speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _check_world_bounds() -> void:
	var r := _get_radius()
	global_position.x = clamp(global_position.x, r, WORLD_W - r)
	global_position.y = clamp(global_position.y, r, WORLD_H - r)

func _update_renderer() -> void:
	if _renderer == null:
		return
	var norm := fmod(facing_angle, TAU)
	if norm > PI / 2.0 or norm < -PI / 2.0:
		_renderer.scale.y = -1.0
	else:
		_renderer.scale.y = 1.0
	_renderer.rotation = facing_angle
	_renderer.anim_tick = anim_tick
	_renderer.claw_anim = claw_anim
	_renderer.queue_redraw()

# --- Attaque griffe / dard ---

func trigger_claw_attack(override_angle: float = -999.0) -> void:
	var sp := SpeciesDB.get_species(species_id)
	if not sp.get("manual_attack", false):
		return
	if claw_cooldown > 0.0:
		return

	claw_cooldown = 0.35
	claw_anim = 0.22

	if override_angle != -999.0:
		facing_angle = override_angle
	else:
		var target := _find_closest_target()
		if target != null:
			facing_angle = global_position.direction_to(target.global_position).angle()

	var reach := _get_radius() + 40.0
	var dmg := float(sp.get("attack_dmg", 50.0))
	stealth_cooldown = 3.0
	is_camouflaged = false

	if GameManager.world == null:
		return
	for bot in GameManager.world.bots:
		if bot == null or bot.is_dead:
			continue
		var d := global_position.distance_to(bot.global_position)
		var ang_to_bot := global_position.direction_to(bot.global_position).angle()
		var diff := absf(ang_to_bot - facing_angle)
		if diff > PI: diff = TAU - diff
		if d < reach + bot.bot_radius and diff < PI / 2.4:
			bot.hp -= dmg
			if bot.hp <= 0.0:
				bot.hp = 0.0
				bot.is_dead = true

	for fish in GameManager.world.passive_fish_list:
		if fish == null or fish.is_dead:
			continue
		var d := global_position.distance_to(fish.global_position)
		var ang_to_fish := global_position.direction_to(fish.global_position).angle()
		var diff := absf(ang_to_fish - facing_angle)
		if diff > PI: diff = TAU - diff
		if d < reach + fish.fish_radius and diff < PI / 2.4:
			fish.is_dead = true

func _find_closest_target() -> Node2D:
	if GameManager.world == null:
		return null
	var closest: Node2D = null
	var min_d := 220.0
	for bot in GameManager.world.bots:
		if bot == null or bot.is_dead: continue
		var d := global_position.distance_to(bot.global_position)
		if d < min_d:
			min_d = d
			closest = bot
	for fish in GameManager.world.passive_fish_list:
		if fish == null or fish.is_dead: continue
		var d := global_position.distance_to(fish.global_position)
		if d < min_d:
			min_d = d
			closest = fish
	return closest

# --- Morsure automatique ---

func try_bite(target: CharacterBody2D) -> void:
	var sp := SpeciesDB.get_species(species_id)
	if sp.get("manual_attack", false):
		return
	if bite_cooldown > 0.0:
		return
	if target is Bot and (target as Bot).is_dead:
		return
	var dmg := float(sp.get("attack_dmg", 25.0))
	bite_cooldown = 0.4
	if target is Bot:
		(target as Bot).hp -= dmg
		stealth_cooldown = 3.0
		is_camouflaged = false
		if (target as Bot).hp <= 0.0:
			(target as Bot).hp = 0.0
			(target as Bot).is_dead = true

# --- Dégâts / soins ---

func take_damage(amount: float) -> void:
	if invuln > 0.0 or is_camouflaged or is_evolving:
		return
	# Poisson-ballon : gonflement déclenché par un coup (réduit les dégâts de 50 %)
	if species_id == "poisson_globe" and puff_cooldown <= 0.0:
		if not is_puffed:
			is_puffed = true
			puff_timer = PUFF_DURATION
		amount *= 0.5
	elif is_puffed:
		amount *= 0.5
	hp -= amount
	invuln = 0.6
	if hp <= 0.0:
		hp = 0.0
		_die()
	GameManager.hp_changed.emit(int(hp), int(max_hp))

func gain_hp(amount: float) -> void:
	hp = min(max_hp, hp + amount)
	GameManager.hp_changed.emit(int(hp), int(max_hp))

func gain_xp(amount: float) -> void:
	var sp := SpeciesDB.get_species(species_id)
	var cap := float(sp.get("xp_to_evolve", 9999))
	xp = min(cap, xp + amount)
	GameManager.xp_changed.emit(int(xp), int(cap))

	if xp >= cap and sp.get("evolves_to", []).size() > 0:
		GameManager.evolve_ready.emit(sp.get("evolves_to", []))

# --- Evolution ---

func start_evolve(target_id: String) -> void:
	is_evolving = true
	evolve_timer = 0.0
	evolve_target_id = target_id
	var tier: int = int(SpeciesDB.get_species(target_id).get("tier", 2))
	evolve_duration = float(SpeciesDB.EVOLVE_DURATION.get(tier, 1.2))
	GameManager.evolve_started.emit()

func _finish_evolve() -> void:
	is_evolving = false
	change_species(evolve_target_id)
	xp = 0.0
	is_camouflaged = false
	stealth_cooldown = 0.0
	GameManager.evolve_finished.emit(evolve_target_id)
	# Débloque le palier pour cette classe à chaque évolution
	var new_sp := SpeciesDB.get_species(evolve_target_id)
	var new_tier: int = int(new_sp.get("tier", 1))
	var new_cls: String = str(new_sp.get("cls", "tank"))
	if new_tier >= 2:
		GameManager.unlock_tier_for_class(new_cls, new_tier)

# --- Mort ---

func _die() -> void:
	is_evolving = false
	xp = 0.0
	is_puffed = false
	puff_timer = 0.0
	puff_cooldown = 0.0
	change_species("crabe")
	global_position = Vector2(WORLD_W / 2.0, WORLD_H / 2.0)
	invuln = 1.5
	is_camouflaged = false
	stealth_cooldown = 0.0
	GameManager.player_died.emit()

# --- Rendu ---

func _draw() -> void:
	if invuln > 0.0:
		modulate.a = 0.6 + 0.4 * sin(Time.get_ticks_msec() * 0.02)
	elif is_camouflaged:
		modulate.a = 0.45
	else:
		modulate.a = 1.0

	# Halo de gonflement (poisson-ballon)
	if is_puffed and species_id == "poisson_globe":
		var r := _get_radius() * 1.4
		draw_circle(Vector2.ZERO, r, Color(1.0, 0.9, 0.2, 0.18))
		draw_arc(Vector2.ZERO, r, 0.0, TAU, 32, Color(1.0, 0.8, 0.0, 0.5), 2.5)

	# Arc de griffe / dard (orienté vers facing_angle)
	if claw_anim > 0.0:
		var r := _get_radius() + 14.0
		draw_arc(Vector2.ZERO, r,
			facing_angle - PI / 2.4, facing_angle + PI / 2.4,
			24, Color(1.0, 0.24, 0.24, 0.9), 5.0)
