extends Node

class_name UpgradePool

static var pool: UpgradePool

@export var upgrades: Array[UnitModifier]

@export var enemy_upgrades: Array[UnitModifier]

var min_cost: int

# Called when the node enters the scene tree for the first time.
func _ready():
	pool = self
	min_cost = enemy_upgrades.reduce(func(min, mod): return mod._mod_val if mod._mod_val < min else min, 1000)
	

func get_random_upgrade() -> UnitModifier:
	return upgrades.pick_random()
	
func get_random_enemy_upgrade() -> UnitModifier:
	return enemy_upgrades.pick_random()

func get_random_enemy_upgrade_set(set_cost) -> Array[UnitModifier]:
	var mods: Array[UnitModifier]
	var remaining_points = set_cost 
	
	while remaining_points >= min_cost:
		var possible_upgrades = enemy_upgrades.filter(func(u): return u._mod_val <= remaining_points)
		var next_mod = possible_upgrades.pick_random()
		if next_mod != null:
			mods.append(next_mod)
			remaining_points -= next_mod._mod_val
		else:
			remaining_points = 0
	return mods

func get_random_upgrade_set(unit) -> Array[UnitModifier]:
	var possible = upgrades.filter(func(u): return unit.is_valid_upgrade(u))
	if possible.size() <= 3:
		return possible
	else:
		possible.shuffle()
		return possible.slice(0,3)
		
