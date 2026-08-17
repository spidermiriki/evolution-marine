extends Node2D
class_name World

const WORLD_W := 3000.0
const WORLD_H := 3000.0
const CENTER  := Vector2(1500.0, 1500.0)

const FOOD_COUNT         := 120
const PASSIVE_FISH_COUNT := 25
const BOT_COUNT          := 22
const ROCK_COUNT         := 26
const CORAL_COUNT        := 22

const BOT_POOL: Array[String] = [
	"crabe", "sole", "aiguille",
	"poisson_globe", "raie", "lotte", "maquereau",
	"baliste", "murene", "bonite",
]

var food_items: Array        = []
var passive_fish_list: Array = []
var bots: Array              = []
var rocks: Array             = []
var corals: Array            = []
var player: Player           = null
var _player_eating_ids: Dictionary = {}

@export var stream_bg:  AudioStream   ## musique de fond en boucle
@export var stream_die: AudioStream   ## son de mort (joueur et bots)

# Scènes préchargées
var FoodScene        := preload("res://scenes/entities/food_item.tscn")
var PassiveFishScene := preload("res://scenes/entities/passive_fish.tscn")
var BotScene         := preload("res://scenes/entities/bot.tscn")
var RockScene        := preload("res://scenes/obstacles/rock.tscn")
var CoralScene       := preload("res://scenes/obstacles/coral.tscn")
var PlayerScene      := preload("res://scenes/player/player.tscn")

func _ready() -> void:
	GameManager.world = self
	_start_bg_music()
	_spawn_player()
	_spawn_rocks(ROCK_COUNT)
	_spawn_corals(CORAL_COUNT)
	_spawn_food(FOOD_COUNT)
	_spawn_passive_fish(PASSIVE_FISH_COUNT)
	for _i in range(BOT_COUNT):
		_spawn_bot()

func _start_bg_music() -> void:
	if stream_bg == null:
		return
	if stream_bg is AudioStreamOggVorbis:
		(stream_bg as AudioStreamOggVorbis).loop = true
	var bgm := AudioStreamPlayer.new()
	bgm.stream = stream_bg
	bgm.volume_db = -8.0
	add_child(bgm)
	bgm.play()

func play_die_sound(pos: Vector2) -> void:
	if stream_die == null: return
	var p := AudioStreamPlayer2D.new()
	p.stream = stream_die
	p.global_position = pos
	p.volume_db = 10.0
	p.max_distance = 1200.0
	add_child(p)
	p.play()
	p.finished.connect(p.queue_free)

func spawn_corpse(pos: Vector2, sid: String, entity_scale: float) -> void:
	var bot := BotScene.instantiate() as Bot
	bot.bot_scale = entity_scale
	add_child(bot)
	bot.global_position = pos
	bot.setup(sid)
	bot.is_dead = true
	bot.hp = 0.0
	bot.queue_redraw()
	bots.append(bot)

func _far_from_center(pos: Vector2) -> bool:
	return pos.distance_to(CENTER) > 260.0

func _random_far_pos(margin: float = 100.0) -> Vector2:
	var pos: Vector2
	var attempts := 0
	while attempts < 100:
		pos = Vector2(randf() * WORLD_W, randf() * (WORLD_H - margin))
		if _far_from_center(pos):
			return pos
		attempts += 1
	return pos

# --- Spawn ---

func _spawn_player() -> void:
	player = PlayerScene.instantiate()
	player.global_position = CENTER
	add_child(player)

func _spawn_rocks(n: int) -> void:
	for _i in range(n):
		var rock := RockScene.instantiate() as Rock
		add_child(rock)
		rock.setup(_random_far_pos())
		rocks.append(rock)

func _spawn_corals(n: int) -> void:
	for _i in range(n):
		var coral := CoralScene.instantiate() as Coral
		add_child(coral)
		coral.setup(_random_far_pos())
		corals.append(coral)

func _spawn_food(n: int) -> void:
	for _i in range(n):
		var f := FoodScene.instantiate() as FoodItem
		add_child(f)
		f.setup()
		food_items.append(f)

func _spawn_passive_fish(n: int) -> void:
	for _i in range(n):
		var pf := PassiveFishScene.instantiate() as PassiveFish
		add_child(pf)
		pf.setup()
		passive_fish_list.append(pf)

func _spawn_bot() -> void:
	var sid := BOT_POOL[randi() % BOT_POOL.size()]
	var bot := BotScene.instantiate() as Bot
	bot.bot_scale = 0.85 + randf() * 0.5
	add_child(bot)
	bot.global_position = _random_far_pos(50.0)
	bot.setup(sid)
	bots.append(bot)

# --- Update ---

func _process(_delta: float) -> void:
	_check_food_collection()
	_check_passive_fish()
	_check_bots()
	queue_redraw()

func _check_food_collection() -> void:
	if player == null:
		return
	var sp := SpeciesDB.get_species(player.species_id)
	var pr: float = float(sp.get("radius", 20.0))

	for i in range(food_items.size() - 1, -1, -1):
		var f: FoodItem = food_items[i]
		if f == null:
			food_items.remove_at(i)
			continue
		if player.global_position.distance_to(f.global_position) < pr + f.radius:
			f.queue_free()
			food_items.remove_at(i)
			player.gain_xp(6.0)
			player.gain_hp(2.0)
			player.trigger_bite()
			_spawn_food(1)

func _check_passive_fish() -> void:
	if player == null:
		return
	var sp := SpeciesDB.get_species(player.species_id)
	var pr: float = float(sp.get("radius", 20.0))

	for i in range(passive_fish_list.size() - 1, -1, -1):
		var pf: PassiveFish = passive_fish_list[i]
		if pf == null:
			passive_fish_list.remove_at(i)
			continue

		var dist := player.global_position.distance_to(pf.global_position)

		if pf.is_dead:
			var eaten_by_player := dist < pr + pf.fish_radius
			var eater_bot: Bot = null
			if not eaten_by_player:
				for bot in bots:
					if bot == null or bot.is_dead: continue
					if bot.global_position.distance_to(pf.global_position) < bot.bot_radius + pf.fish_radius:
						eater_bot = bot
						break
			if eaten_by_player or eater_bot != null:
				var pid := pf.get_instance_id()
				if eaten_by_player and pid not in _player_eating_ids:
					player.trigger_eat_start(1)
					_player_eating_ids[pid] = true
				elif not eaten_by_player:
					_player_eating_ids.erase(pid)
				pf.eat_progress += get_process_delta_time()
				pf.queue_redraw()
				if pf.eat_progress >= pf.eat_duration:
					_player_eating_ids.erase(pid)
					if eaten_by_player:
						player.gain_xp(4.0)
					else:
						eater_bot.hp = min(eater_bot.max_hp, eater_bot.hp + 15.0)
					pf.queue_free()
					passive_fish_list.remove_at(i)
					_spawn_passive_fish(1)
		else:
			# Morsure auto si pas d'attaque manuelle
			if not sp.get("manual_attack", false):
				if dist < pr + pf.fish_radius and player.bite_cooldown <= 0.0:
					pf.is_dead = true
					player.bite_cooldown = 0.4
					player.stealth_cooldown = 3.0
					player.is_camouflaged = false
					player.trigger_bite()

func _check_bots() -> void:
	if player == null:
		return
	var sp := SpeciesDB.get_species(player.species_id)
	var pr: float = float(sp.get("radius", 20.0))

	# Nourriture mangée par bots
	for bot in bots:
		if bot == null or bot.is_dead: continue
		for i in range(food_items.size() - 1, -1, -1):
			var f: FoodItem = food_items[i]
			if f == null:
				food_items.remove_at(i)
				continue
			if bot.global_position.distance_to(f.global_position) < bot.bot_radius + f.radius:
				f.queue_free()
				food_items.remove_at(i)
				bot.hp = min(bot.max_hp, bot.hp + 4.0)
				_spawn_food(1)
				break

	# Bots morts mangés par joueur ou par d'autres bots
	for i in range(bots.size() - 1, -1, -1):
		var bot: Bot = bots[i]
		if bot == null:
			bots.remove_at(i)
			continue
		if not bot.is_dead: continue

		var dist := player.global_position.distance_to(bot.global_position)
		var eaten_by_player := dist < pr + bot.bot_radius
		var eater_bot: Bot = null
		if not eaten_by_player:
			for other in bots:
				if other == null or other.is_dead or other == bot: continue
				if other.global_position.distance_to(bot.global_position) < other.bot_radius + bot.bot_radius:
					eater_bot = other
					break
		if eaten_by_player or eater_bot != null:
			var bid := bot.get_instance_id()
			if eaten_by_player and bid not in _player_eating_ids:
				var bot_tier := int(SpeciesDB.get_species(bot.species_id).get("tier", 1))
				player.trigger_eat_start(bot_tier)
				_player_eating_ids[bid] = true
			elif not eaten_by_player:
				_player_eating_ids.erase(bid)
			bot.eat_progress += get_process_delta_time()
			bot.queue_redraw()
			if bot.eat_progress >= bot.eat_duration:
				_player_eating_ids.erase(bid)
				var bot_sp := SpeciesDB.get_species(bot.species_id)
				var tier: int = int(bot_sp.get("tier", 1))
				var bot_r: float = float(bot_sp.get("radius", 20.0)) * bot.bot_scale
				if eaten_by_player:
					player.gain_xp(10.0 + float(tier) * 20.0 + bot_r * 1.5)
					player.gain_hp(35.0)
				else:
					eater_bot.hp = min(eater_bot.max_hp, eater_bot.hp + 35.0)
				bot.queue_free()
				bots.remove_at(i)
				_spawn_bot()

	# Morsure joueur sur bots vivants
	if not sp.get("manual_attack", false):
		for bot in bots:
			if bot == null or bot.is_dead: continue
			var dist := player.global_position.distance_to(bot.global_position)
			if dist < pr + bot.bot_radius:
				player.try_bite(bot)

# --- Dessin du monde ---

func _draw() -> void:
	# Grille
	var grid_color := Color(1, 1, 1, 0.04)
	var step := 100.0
	var x := 0.0
	while x <= WORLD_W:
		draw_line(Vector2(x, 0), Vector2(x, WORLD_H), grid_color, 1.0)
		x += step
	var y := 0.0
	while y <= WORLD_H:
		draw_line(Vector2(0, y), Vector2(WORLD_W, y), grid_color, 1.0)
		y += step

	# Bordures monde
	var border := Color(1, 0.3, 0.3, 0.5)
	draw_line(Vector2(0, 0),       Vector2(0, WORLD_H),       border, 8.0)
	draw_line(Vector2(WORLD_W, 0), Vector2(WORLD_W, WORLD_H), border, 8.0)
	draw_line(Vector2(0, 0),       Vector2(WORLD_W, 0),        border, 8.0)
	# Fond sableux
	draw_line(Vector2(0, WORLD_H), Vector2(WORLD_W, WORLD_H), Color("dcae68"), 16.0)
