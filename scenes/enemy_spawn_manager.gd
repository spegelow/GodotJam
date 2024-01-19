extends Node

class_name EnemySpawnManager

static var spawn_manager: EnemySpawnManager

@export var enemy_data: UnitData

@export var upgrade_interval = 10
@export var amount_decrease_on_upgrade = 2
@export var amount_interval = 5
@export var spawn_interval = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_manager = self

func create_new_spawner(turn_num):
	if turn_num == 1 or turn_num % spawn_interval == 0:
		var tile = BattleMap.map.tiles.filter(func(t): return t.occupant == null and not BattleMap.map.spawners.any(func(s): s.tile == t)).pick_random()
		var spawner = EnemySpawnPortal.build_spawner(tile)
		BattleMap.map.add_child(spawner)
		BattleMap.map.spawners.append(spawner)
		
		var upgrade_count = turn_num / upgrade_interval
		var enemy_count = turn_num / amount_interval - upgrade_count*amount_decrease_on_upgrade + 1
		
		for i in range(0, upgrade_count):
			spawner.modifiers.append(UpgradePool.pool.get_random_upgrade())

		for i in range(0, enemy_count):
			spawner.enemies_to_spawn.append(enemy_data)
