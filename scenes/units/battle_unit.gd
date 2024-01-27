extends Node2D

class_name BattleUnit

const UNIT_SCENE = preload("res://scenes/units/battle_unit.tscn")

var is_player_unit = true
var is_base = false

var can_move = false
var can_attack = false

var unit_data: UnitData

var current_health
var current_exp
var current_level
var current_tile

var exp_per_level = 10


@export var modifiers: Array[UnitModifier]

@export var death_sound: AudioStream
@export var hit_sound: AudioStream
@export var level_sound: AudioStream

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func get_stat(stat) -> Variant:
	var base_val = unit_data.get_stat(stat)
	var modded_val = modifiers.reduce(func(value, mod): return mod.modify_stat(stat, value), base_val)
	
	#Adjust exp based on level
	if stat == "exp_value":
		modded_val *= current_level 

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
	
	instance.on_health_changed(0)
	
	instance.update_sprite()
	
	return instance

# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_enemy_unit(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance: BattleUnit = UNIT_SCENE.instantiate()
	instance.current_tile = tile
	tile.occupant = instance
	instance.position = tile.coordinate * scale
	
	instance.current_exp = 0
	instance.current_level = 1
	
	instance.unit_data = data
	instance.current_health = instance.get_stat('max_health')
	instance.on_health_changed(0)
	
	instance.is_player_unit = false
	
	instance.update_sprite()
	
	return instance

# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_base(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance: BattleUnit = UNIT_SCENE.instantiate()
	instance.current_tile = tile
	tile.occupant = instance
	instance.position = tile.coordinate * scale
	
	instance.current_exp = 0
	instance.current_level = 1
	
	instance.unit_data = data
	instance.current_health = instance.get_stat('max_health')
	instance.on_health_changed(0)
	
	instance.is_player_unit = true
	instance.is_base = true
	
	instance.update_sprite()
	
	return instance

func get_moveable_tiles() -> Array:
	var tiles = BattleMap.map.get_tiles_in_range(current_tile, get_stat('movement'))
	return tiles.filter(func(t: MapTile): return t.occupant == null)

func get_attackable_tiles() -> Array:
	var tiles = BattleMap.map.get_tiles_in_range(current_tile, get_stat('range'))
	return tiles.filter(func(t: MapTile): return t.occupant != null and t.occupant != self and t.occupant.is_player_unit != self.is_player_unit)

func move_to(tile: MapTile, scale = 128):
	current_tile.occupant = null
	current_tile = tile
	tile.occupant = self
	position = tile.coordinate * scale
	can_move = false
	await get_tree().create_timer(.2).timeout

func attack(unit: BattleUnit):
	unit.apply_damage(get_stat('attack'))
	
	if unit.current_health <= 0:
		#Got a kill???
		await award_exp(unit.get_stat('exp_value'))
	
	can_move = false
	can_attack = false
	if is_player_unit:
		BattleMap.map.on_player_attack_resolved()
	await get_tree().create_timer(.1).timeout

func apply_damage(amount):
	var damage = amount - get_stat('defense')
	damage = max(0, damage)
	current_health -= damage
	on_health_changed(0)
	DamageText.display_damage_text(damage, self.position)
	AudioPlayer.instance.play_effect(hit_sound)
	if current_health <= 0:
		BattleMap.map.resolve_unit_death(self)
		if not is_player_unit:
			BattleMap.map.points += get_stat("exp_value")
			BattleMap.map.point_counter.text = str(BattleMap.map.points)

func award_exp(amount):
	current_exp += amount
	while current_exp >= exp_per_level:
		current_exp -= exp_per_level
		await level_up()

func level_up():
	AudioPlayer.instance.play_effect(level_sound)
	current_level += 1
	LevelUpMenu.menu.set_up_menu(self)
	await LevelUpMenu.menu.menu_closed 

func add_upgrade(u):
	modifiers.append(u)

func resolve_enemy_turn():
	var a_tiles = get_attackable_tiles()
	var m_tiles = get_moveable_tiles()
	
	#Check if base is in attack range
	var t = a_tiles.filter(func(t): return t.occupant.is_base).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await attack(t.occupant)
		return
	
	#Check if a player unit is in attack range
	t = a_tiles.filter(func(t): return t.occupant.is_player_unit).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await attack(t.occupant)
		return
	
	#Check if can move to a tile within range of the base
	t = m_tiles.filter(func(t): return BattleMap.map.get_tiles_in_range(t, get_stat('range')).any(func(t2): return t2.occupant!=null and t2.occupant.is_base)).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await move_to(t)
		a_tiles = get_attackable_tiles()
		var t2 = a_tiles.filter(func(t): return t.occupant!=null and t.occupant.is_base).front()
		if t2 != null:
			await get_tree().create_timer(.1).timeout
			await attack(t2.occupant)
		return
	
	#Check if can move to a tile within range of the player
	t = m_tiles.filter(func(t): return BattleMap.map.get_tiles_in_range(t, get_stat('range')).any(func(t2): return t2.occupant!=null and t2.occupant.is_player_unit)).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await move_to(t)
		a_tiles = get_attackable_tiles()
		var t2 = a_tiles.filter(func(t): return t.occupant!=null and t.occupant.is_player_unit).front()
		if t2 != null:
			await get_tree().create_timer(.1).timeout
			await attack(t2.occupant)
		return
		
	#Otherwise move as close as possible to the base
	var base_pos = BattleMap.map.player_base.current_tile.coordinate
	t = m_tiles.reduce(func(max, val): return val if is_closer(val.coordinate, max.coordinate, base_pos) else max, current_tile)
	if t != null:
		await get_tree().create_timer(.1).timeout
		await move_to(t)
		a_tiles = get_attackable_tiles()
		var t2 = a_tiles.filter(func(t): return t.occupant!=null and t.occupant.is_player_unit).front()
		if t2 != null:
			await get_tree().create_timer(.1).timeout
			await attack(t2.occupant)
		return


func is_closer(a,b, target) -> bool:
	return a.distance_to(target) <= b.distance_to(target)

func on_health_changed(amount):
	$HealthLabel.text = str(current_health)

func is_valid_upgrade(u) -> bool:
	if u._required_tag == "":
		return true
	elif not unit_data._tag_list.has(u._required_tag):
		return false
		
	return true

func update_sprite():
	$UnitSprite.texture = unit_data.unit_sprite
