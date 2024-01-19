extends Node2D

class_name BattleUnit

const UNIT_SCENE = preload("res://scenes/units/battle_unit.tscn")
const ENEMY_UNIT_SCENE = preload("res://scenes/units/enemy_battle_unit.tscn")
const BASE_SCENE = preload("res://scenes/units/base_battle_unit.tscn")

var is_player_unit = true
var is_base = false

var can_move = false
var can_attack = false

var unit_data: UnitData

var current_health
var current_exp
var current_level
var current_tile

@export var modifiers: Array[UnitModifier]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_stat(stat) -> Variant:
	var base_val = unit_data.get_stat(stat)
	var modded_val = modifiers.reduce(func(value, mod): return mod.modify_stat(stat, value), base_val)

	return modded_val


# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_unit(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance: BattleUnit = UNIT_SCENE.instantiate()
	instance.current_tile = tile
	tile.occupant = instance
	instance.position = tile.coordinate * scale
	
	instance.current_exp = 0
	instance.current_level = 1
	
	instance.unit_data = data
	instance.current_health = instance.get_stat('max_health')
	
	return instance

# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_enemy_unit(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance: BattleUnit = ENEMY_UNIT_SCENE.instantiate()
	instance.current_tile = tile
	tile.occupant = instance
	instance.position = tile.coordinate * scale
	
	instance.current_exp = 0
	instance.current_level = 1
	
	instance.unit_data = data
	instance.current_health = instance.get_stat('max_health')
	
	instance.is_player_unit = false
	
	return instance

# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_base(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance: BattleUnit = BASE_SCENE.instantiate()
	instance.current_tile = tile
	tile.occupant = instance
	instance.position = tile.coordinate * scale
	
	instance.current_exp = 0
	instance.current_level = 1
	
	instance.unit_data = data
	instance.current_health = instance.get_stat('max_health')
	
	instance.is_player_unit = false
	instance.is_base = true
	
	return instance

func get_moveable_tiles() -> Array:
	var tiles = BattleMap.map.get_tiles_in_range(current_tile, get_stat('movement'))
	return tiles.filter(func(t: MapTile): return t.occupant == null)

func get_attackable_tiles() -> Array:
	var tiles = BattleMap.map.get_tiles_in_range(current_tile, get_stat('range'))
	return tiles.filter(func(t: MapTile): return t.occupant != null)

func move_to(tile: MapTile, scale = 128):
	current_tile.occupant = null
	current_tile = tile
	tile.occupant = self
	position = tile.coordinate * scale
	can_move = false
	await get_tree().create_timer(.2).timeout

func attack(unit: BattleUnit):
	unit.apply_damage(get_stat('attack'))
	
	if unit.current_health < 0:
		#Got a kill???
		award_exp(unit.get_stat('exp_value'))
	
	can_move = false
	can_attack = false
	if is_player_unit:
		BattleMap.map.on_player_attack_resolved()
	await get_tree().create_timer(.1).timeout

func apply_damage(amount):
	var damage = amount - get_stat('defense')
	current_health -= damage
	DamageText.display_damage_text(damage, self.position)
	if current_health <= 0:
		BattleMap.map.resolve_unit_death(self)

func award_exp(amount):
	current_exp += amount
	while current_exp >= 10:
		current_exp -= 10
		level_up()

func level_up():
	print("Level up")
	current_level += 1
	modifiers.append(UpgradePool.pool.get_random_upgrade())

func resolve_enemy_turn():
	var a_tiles = get_attackable_tiles()
	var m_tiles = get_moveable_tiles()
	
	#Check if base is in attack range
	var t = a_tiles.filter(func(t): return t.occupant.is_base).front()
	if t != null:
		await attack(t.occupant)
		return
	
	#Check if a player unit is in attack range
	t = a_tiles.filter(func(t): return t.occupant.is_player_unit).front()
	if t != null:
		await attack(t.occupant)
		return
	
	#Check if can move to a tile within range of the base
	t = m_tiles.filter(func(t): return BattleMap.map.get_tiles_in_range(t, get_stat('range')).any(func(t2): return t2.occupant!=null and t2.occupant.is_base)).front()
	if t != null:
		await move_to(t)
		a_tiles = get_attackable_tiles()
		var t2 = a_tiles.filter(func(t): return t.occupant!=null and t.occupant.is_base).front()
		if t2 != null:
			await attack(t2.occupant)
		return
	
	#Check if can move to a tile within range of the player
	t = m_tiles.filter(func(t): return BattleMap.map.get_tiles_in_range(t, get_stat('range')).any(func(t2): return t2.occupant!=null and t2.occupant.is_player_unit)).front()
	if t != null:
		await move_to(t)
		a_tiles = get_attackable_tiles()
		var t2 = a_tiles.filter(func(t): return t.occupant!=null and t.occupant.is_player_unit).front()
		if t2 != null:
			await attack(t2.occupant)
		return
		
	#Otherwise move as close as possible to the base
	var base_pos = BattleMap.map.player_base.current_tile.coordinate
	t = m_tiles.reduce(func(max, val): return val if is_closer(val.coordinate, max.coordinate, base_pos) else max, current_tile)
	if t != null:
		await move_to(t)
		a_tiles = get_attackable_tiles()
		var t2 = a_tiles.filter(func(t): return t.occupant!=null and t.occupant.is_player_unit).front()
		if t2 != null:
			await attack(t2.occupant)
		return


func is_closer(a,b, target) -> bool:
	return a.distance_to(target) <= b.distance_to(target)
