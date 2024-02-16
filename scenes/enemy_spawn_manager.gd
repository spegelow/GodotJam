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

@export var enemies: Array[UnitData]

var next_enemy: UnitData
var next_modifiers: Array[UnitModifier]
var next_enemy_count: int

@export var spawn_points: Array[Vector2]
var spawns

func _init():
	spawn_manager = self

func create_new_spawner():
	if spawns == null:
		spawns = spawn_points.map(func(t): return BattleMap.instance.get_map_tile(t.x, t.y))
	
	
	var tile = spawns.filter(func(t): return t.occupant == null and not BattleMap.instance.spawners.any(func(s): s.tile == t)).pick_random()
	if tile != null:
		var spawner = EnemySpawnPortal.build_spawner(tile)
		BattleMap.instance.add_child(spawner)
		BattleMap.instance.spawners.append(spawner)
	
		var enemy_count = next_enemy_count
		
		spawner.modifiers = next_modifiers.duplicate()
		
		for i in range(0, enemy_count):
			spawner.enemies_to_spawn.append(next_enemy)
		
		spawner.adjust_count()

func create_new_spawner_old(turn_num):
	if turn_num == 1 or turn_num % spawn_interval == 0 and turn_num % boss_spawn_interval != 0:
		BattleMap.instance.wave_num+=1
		BattleMap.instance.wave_counter.text = str(BattleMap.instance.wave_num)
		var tile = BattleMap.instance.tiles.filter(func(t): return t.occupant == null and not BattleMap.instance.spawners.any(func(s): s.tile == t)).pick_random()
		var spawner = EnemySpawnPortal.build_spawner(tile)
		BattleMap.instance.add_child(spawner)
		BattleMap.instance.spawners.append(spawner)
		
		spawner.spawner_level = turn_num / upgrade_interval + 1
		var enemy_count = turn_num / amount_interval - (spawner.spawner_level-1)*amount_decrease_on_upgrade + 1
		
		spawner.modifiers = UpgradePool.pool.get_random_enemy_upgrade_set((spawner.spawner_level-1) * points_per_upgrade)
		
		for i in range(0, enemy_count):
			spawner.enemies_to_spawn.append(enemies.pick_random())
		
		spawner.adjust_count()
	if turn_num % boss_spawn_interval == 0:
		var tile = BattleMap.instance.tiles.filter(func(t): return t.occupant == null and not BattleMap.instance.spawners.any(func(s): s.tile == t)).pick_random()
		var spawner = EnemySpawnPortal.build_spawner(tile)
		BattleMap.instance.add_child(spawner)
		BattleMap.instance.spawners.append(spawner)
		
		spawner.spawner_level = turn_num / upgrade_interval + 1
		var enemy_count = turn_num / amount_interval - (spawner.spawner_level-1)*amount_decrease_on_upgrade + 1
		
		spawner.modifiers = UpgradePool.pool.get_random_enemy_upgrade_set((spawner.spawner_level-1) * points_per_upgrade)
		
		spawner.enemies_to_spawn.append(boss_data)
		
		spawner.adjust_count()

func prepare_next_wave(wave_num: int):
	var points = wave_num
	next_enemy = enemy_data
	next_modifiers = UpgradePool.pool.get_random_enemy_upgrade_set(points)
	next_enemy_count = max(min((wave_num / 2) as int, 10), 1)
	
