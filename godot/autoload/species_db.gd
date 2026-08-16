extends Node

const SPECIES: Dictionary = {
	# ── PALIER 1 ──────────────────────────────────────────────────────────────
	"crabe": {
		"name": "Crabe dormeur", "emoji": "🦀", "tier": 1, "cls": "tank",
		"radius": 22.0, "speed": 140.0, "xp_to_evolve": 80,
		"max_hp": 130, "manual_attack": true,
		"evolves_to": ["poisson_globe", "raie", "lotte", "maquereau"]
	},
	"sole": {
		"name": "Sole", "emoji": "🐟", "tier": 1, "cls": "furtif",
		"radius": 20.0, "speed": 155.0, "xp_to_evolve": 80,
		"max_hp": 100, "manual_attack": false,
		"evolves_to": ["poisson_globe", "raie", "lotte", "maquereau"]
	},
	"aiguille": {
		"name": "Poisson-aiguille", "emoji": "🐟", "tier": 1, "cls": "rapide",
		"radius": 16.0, "speed": 240.0, "xp_to_evolve": 80,
		"max_hp": 85, "manual_attack": false,
		"evolves_to": ["poisson_globe", "raie", "lotte", "maquereau"]
	},

	# ── PALIER 2 ──────────────────────────────────────────────────────────────
	"poisson_globe": {
		"name": "Poisson-globe", "emoji": "🐡", "tier": 2, "cls": "tank",
		"radius": 28.0, "speed": 160.0, "xp_to_evolve": 180,
		"max_hp": 280, "manual_attack": false,
		"evolves_to": ["baliste", "murene", "bonite"]
	},
	"raie": {
		"name": "Raie des sables", "emoji": "🟤", "tier": 2, "cls": "furtif",
		"radius": 24.0, "speed": 185.0, "xp_to_evolve": 180,
		"max_hp": 210, "manual_attack": false,
		"evolves_to": ["baliste", "murene", "bonite"]
	},
	"lotte": {
		"name": "Lotte", "emoji": "🐟", "tier": 2, "cls": "furtif",
		"radius": 26.0, "speed": 170.0, "xp_to_evolve": 180,
		"max_hp": 240, "manual_attack": false,
		"evolves_to": ["baliste", "murene", "bonite"]
	},
	"maquereau": {
		"name": "Maquereau", "emoji": "🐟", "tier": 2, "cls": "rapide",
		"radius": 20.0, "speed": 310.0, "xp_to_evolve": 180,
		"max_hp": 160, "manual_attack": false,
		"evolves_to": ["baliste", "murene", "bonite"]
	},

	# ── PALIER 3 ──────────────────────────────────────────────────────────────
	"baliste": {
		"name": "Baliste titan", "emoji": "🐡", "tier": 3, "cls": "tank",
		"radius": 32.0, "speed": 200.0, "xp_to_evolve": 350,
		"max_hp": 450, "manual_attack": true,
		"evolves_to": ["merou_geant", "wobbegong", "barracuda"]
	},
	"murene": {
		"name": "Murène", "emoji": "🐍", "tier": 3, "cls": "furtif",
		"radius": 30.0, "speed": 215.0, "xp_to_evolve": 350,
		"max_hp": 380, "manual_attack": false,
		"evolves_to": ["merou_geant", "wobbegong", "barracuda"]
	},
	"bonite": {
		"name": "Bonite", "emoji": "🐟", "tier": 3, "cls": "rapide",
		"radius": 26.0, "speed": 340.0, "xp_to_evolve": 350,
		"max_hp": 260, "manual_attack": false,
		"evolves_to": ["merou_geant", "wobbegong", "barracuda"]
	},

	# ── PALIER 4 ──────────────────────────────────────────────────────────────
	"merou_geant": {
		"name": "Mérou géant", "emoji": "🐟", "tier": 4, "cls": "tank",
		"radius": 42.0, "speed": 200.0, "xp_to_evolve": 9999,
		"max_hp": 850, "manual_attack": false,
		"evolves_to": []
	},
	"wobbegong": {
		"name": "Wobbegong", "emoji": "🦈", "tier": 4, "cls": "furtif",
		"radius": 36.0, "speed": 220.0, "xp_to_evolve": 9999,
		"max_hp": 600, "manual_attack": false,
		"evolves_to": []
	},
	"barracuda": {
		"name": "Barracuda", "emoji": "🐟", "tier": 4, "cls": "rapide",
		"radius": 28.0, "speed": 420.0, "xp_to_evolve": 9999,
		"max_hp": 380, "manual_attack": false,
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
	4: Color("f87171")
}

# Débloquées par défaut : palier 1 uniquement
const DEFAULT_UNLOCKED: Array[String] = [
	"crabe", "sole", "aiguille"
]

const EVOLVE_DURATION: Dictionary = {
	2: 0.9, 3: 1.5, 4: 2.5
}

func get_species(id: String) -> Dictionary:
	return SPECIES.get(id, {})
