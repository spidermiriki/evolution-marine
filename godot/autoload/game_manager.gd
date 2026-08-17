extends Node

signal hp_changed(hp: int, max_hp: int)
signal xp_changed(xp: int, max_xp: int)
signal stamina_changed(value: float)
signal species_changed(species_id: String)
signal player_died
signal respawn_needed
signal evolve_ready(choices: Array)
signal evolve_started
signal evolve_finished(new_id: String)
signal species_unlocked(ids: Array)

# Références globales
var player: CharacterBody2D = null
var world: Node2D = null

# Espèces débloquées pour le choix de départ
var unlocked_species: Array[String] = []

func _ready() -> void:
	unlocked_species = SpeciesDB.DEFAULT_UNLOCKED.duplicate()

func is_unlocked(species_id: String) -> bool:
	return unlocked_species.has(species_id)

# Appelé quand le joueur atteint un nouveau palier en jeu.
# Débloque toutes les espèces de cette classe à ce palier.
func unlock_tier_for_class(cls: String, tier: int) -> void:
	var newly: Array[String] = []
	for id in SpeciesDB.SPECIES:
		var sp: Dictionary = SpeciesDB.SPECIES[id]
		if str(sp.get("cls", "")) == cls and int(sp.get("tier", 1)) == tier:
			if not unlocked_species.has(id):
				unlocked_species.append(id)
				newly.append(id)
	if newly.size() > 0:
		species_unlocked.emit(newly)
