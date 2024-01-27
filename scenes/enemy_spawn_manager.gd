extends Node

class_name EnemySpawnManager

static var spawn_manager: EnemySpawnManager

@export var enemy_data: UnitData
@export var boss_data: UnitData

@export var upgrade_interval = 10
@export var points_per_upgrade = 10
@export var amount_decrease_on_upgrade = 2
@export var amount_interval = 5
@export var spawn_interval = 2
@export var boss_spawn_interval = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_manager = self

func create_new_spawner(turn_num):
	if turn_num == 1 or turn_num % spawn_interval == 0 and turn_num % boss_spawn_interval != 0:
		BattleMap.map.wave_num+=1
		BattleMap.map.wave_counter.text = str(BattleMap.map.wave_num)
		var tile = BattleMap.map.tiles.filter(func(t): return t.occupant == null and not BattleMap.map.spawners.any(func(s): s.tile == t)).pick_random()
		var spawner = EnemySpawnPortal.build_spawner(tile)
		BattleMap.map.add_child(spawner)
		BattleMap.map.spawners.append(spawner)
		
		spawner.spawner_level = turn_num / upgrade_interval + 1
		var enemy_count = turn_num / amount_interval - (spawner.spawner_level-1)*amount_decrease_on_upgrade + 1
		
		spawner.modifiers = UpgradePool.pool.get_random_enemy_upgrade_set((spawner.spawner_level-1) * points_per_upgrade)
		
		for i in range(0, enemy_count):
			spawner.enemies_to_spawn.append(enemy_data)
		
		spawner.adjust_count()
	if turn_num % boss_spawn_interval == 0:
		var tile = BattleMap.map.tiles.filter(func(t): return t.occupant == null and not BattleMap.map.spawners.any(func(s): s.tile == t)).pick_random()
		var spawner = EnemySpawnPortal.build_spawner(tile)
		BattleMap.map.add_child(spawner)
		BattleMap.map.spawners.append(spawner)
		
		spawner.spawner_level = turn_num / upgrade_interval + 1
		var enemy_count = turn_num / amount_interval - (spawner.spawner_level-1)*amount_decrease_on_upgrade + 1
		
		spawner.modifiers = UpgradePool.pool.get_random_enemy_upgrade_set((spawner.spawner_level-1) * points_per_upgrade)
		
		spawner.enemies_to_spawn.append(boss_data)
		
		spawner.adjust_count()
