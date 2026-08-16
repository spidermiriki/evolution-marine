extends Node

const SPECIES: Dictionary = {
	# ── PALIER 1 ──────────────────────────────────────────────────────────────
	"crabe": {
		"name": "Crabe nageur", "emoji": "🦀", "tier": 1, "cls": "tank",
		"radius": 22.0, "speed": 140.0, "xp_to_evolve": 80,
		"max_hp": 100, "manual_attack": true, "attack_dmg": 25.0,
		"stamina_drain": 16.7,
		"evolves_to": ["poisson_globe", "raie", "lotte", "maquereau"]
	},
	"sole": {
		"name": "Sole commune", "emoji": "🐟", "tier": 1, "cls": "furtif",
		"radius": 18.0, "speed": 115.0, "xp_to_evolve": 80,
		"max_hp": 60, "manual_attack": false, "attack_dmg": 12.0,
		"stamina_drain": 25.0,
		"evolves_to": ["poisson_globe", "raie", "lotte", "maquereau"]
	},
	"aiguille": {
		"name": "Poisson-aiguille", "emoji": "🐟", "tier": 1, "cls": "rapide",
		"radius": 12.0, "speed": 235.0, "xp_to_evolve": 80,
		"max_hp": 50, "manual_attack": false, "attack_dmg": 8.0,
		"stamina_drain": 50.0,
		"evolves_to": ["poisson_globe", "raie", "lotte", "maquereau"]
	},

	# ── PALIER 2 ──────────────────────────────────────────────────────────────
	# Poisson-ballon : tank défensif, se gonfle quand blessé (géré dans player.gd)
	"poisson_globe": {
		"name": "Poisson-ballon", "emoji": "🐡", "tier": 2, "cls": "tank",
		"radius": 28.0, "speed": 115.0, "xp_to_evolve": 200,
		"max_hp": 180, "manual_attack": false, "attack_dmg": 20.0,
		"stamina_drain": 16.7,
		"evolves_to": ["baliste", "murene", "bonite"]
	},
	# Raie pastenague : furtif dans le sable, dard manuel
	"raie": {
		"name": "Raie pastenague", "emoji": "🟤", "tier": 2, "cls": "furtif",
		"radius": 26.0, "speed": 235.0, "xp_to_evolve": 200,
		"max_hp": 130, "manual_attack": true, "attack_dmg": 35.0,
		"stamina_drain": 12.5,
		"evolves_to": ["baliste", "murene", "bonite"]
	},
	# Lotte : furtif dans le sable, prédateur en embuscade
	"lotte": {
		"name": "Lotte commune", "emoji": "🐟", "tier": 2, "cls": "furtif",
		"radius": 24.0, "speed": 110.0, "xp_to_evolve": 200,
		"max_hp": 160, "manual_attack": false, "attack_dmg": 32.0,
		"stamina_drain": 22.0,
		"evolves_to": ["baliste", "murene", "bonite"]
	},
	# Maquereau : rapide, agile
	"maquereau": {
		"name": "Maquereau commun", "emoji": "🐟", "tier": 2, "cls": "rapide",
		"radius": 18.0, "speed": 320.0, "xp_to_evolve": 200,
		"max_hp": 120, "manual_attack": false, "attack_dmg": 20.0,
		"stamina_drain": 14.0,
		"evolves_to": ["baliste", "murene", "bonite"]
	},

	# ── PALIER 3 ──────────────────────────────────────────────────────────────
	"baliste": {
		"name": "Baliste titan", "emoji": "🐡", "tier": 3, "cls": "tank",
		"radius": 28.0, "speed": 185.0, "xp_to_evolve": 500,
		"max_hp": 320, "manual_attack": false, "attack_dmg": 55.0,
		"stamina_drain": 16.7,
		"evolves_to": ["merou_geant", "wobbegong", "barracuda"]
	},
	# Murène : furtif dans les rochers
	"murene": {
		"name": "Murène méditerranéenne", "emoji": "🐍", "tier": 3, "cls": "furtif",
		"radius": 22.0, "speed": 200.0, "xp_to_evolve": 500,
		"max_hp": 280, "manual_attack": false, "attack_dmg": 50.0,
		"stamina_drain": 20.0,
		"evolves_to": ["merou_geant", "wobbegong", "barracuda"]
	},
	"bonite": {
		"name": "Bonite à ventre rayé", "emoji": "🐟", "tier": 3, "cls": "rapide",
		"radius": 22.0, "speed": 380.0, "xp_to_evolve": 500,
		"max_hp": 240, "manual_attack": false, "attack_dmg": 45.0,
		"stamina_drain": 12.5,
		"evolves_to": ["merou_geant", "wobbegong", "barracuda"]
	},

	# ── PALIER 4 ──────────────────────────────────────────────────────────────
	"merou_geant": {
		"name": "Mérou géant", "emoji": "🐟", "tier": 4, "cls": "tank",
		"radius": 42.0, "speed": 190.0, "xp_to_evolve": 9999,
		"max_hp": 850, "manual_attack": false, "attack_dmg": 80.0,
		"stamina_drain": 10.0,
		"evolves_to": []
	},
	"wobbegong": {
		"name": "Wobbegong", "emoji": "🦈", "tier": 4, "cls": "furtif",
		"radius": 36.0, "speed": 210.0, "xp_to_evolve": 9999,
		"max_hp": 600, "manual_attack": false, "attack_dmg": 70.0,
		"stamina_drain": 12.5,
		"evolves_to": []
	},
	"barracuda": {
		"name": "Barracuda", "emoji": "🐟", "tier": 4, "cls": "rapide",
		"radius": 30.0, "speed": 420.0, "xp_to_evolve": 9999,
		"max_hp": 380, "manual_attack": false, "attack_dmg": 65.0,
		"stamina_drain": 8.3,
		"evolves_to": []
	},
}

const CLASS_COLOR: Dictionary = {
	"tank":   Color(1.0,  0.42, 0.29),
	"rapide": Color(1.0,  0.82, 0.25),
	"furtif": Color(0.44, 0.55, 1.0)
}

const TIER_COLOR: Dictionary = {
	1: Color("4ade80"),
	2: Color("60a5fa"),
	3: Color("fb923c"),
	4: Color("e879f9"),
}

# Débloquées par défaut : palier 1 uniquement
const DEFAULT_UNLOCKED: Array[String] = [
	"crabe", "sole", "aiguille"
]

const EVOLVE_DURATION: Dictionary = {
	2: 1.2, 3: 2.0, 4: 3.0
}

func get_species(id: String) -> Dictionary:
	return SPECIES.get(id, {})
