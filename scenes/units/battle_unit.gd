extends Node2D

class_name BattleUnit

const UNIT_SCENE = preload("res://scenes/units/battle_unit.tscn")

var is_player_unit = true
var is_base = false

var can_move = false
var can_attack = false

var unit_data: UnitData

var items: Array[ItemData]


var current_health
var current_exp
var current_level
var current_tile

var exp_per_level = 10

var current_unit_stacks = 1


@export var modifiers: Array[UnitModifier]

@export var death_sound: AudioStream
@export var attack_sound: AudioStream
@export var hit_sound: AudioStream
@export var level_sound: AudioStream


var _moveable_tiles: Array[MapTile]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_actions() -> Array[BattleAction]:
	var actions: Array[BattleAction] = [unit_data.attack_action]
	
	for i in items:
		if i.usable_action != null:
			actions.append(i.usable_action)
	
	return actions

func get_stat(stat) -> Variant:
	var base_val = unit_data.get_stat(stat)
	var modded_val = modifiers.reduce(func(value, mod): return mod.modify_stat(stat, value), base_val)
	
	if stat == "defense":
		modded_val += current_tile.get_defense_bonus()
		modded_val = items.reduce(func(value, i): return modded_val + i.defense_boost, modded_val)
	if stat == 'attack':
		modded_val = items.reduce(func(value, i): return modded_val + i.attack_boost, modded_val)
		
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
	instance.current_unit_stacks = instance.get_stat('stack_cap')
	
	instance.items = data.starting_items.duplicate()
	
	instance.on_health_changed(0)
	
	instance.update_sprite()
	
	return instance

# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_base(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance = build_unit(data, tile, scale)
	
	instance.is_player_unit = true
	instance.is_base = true
	return instance

func get_moveable_tiles() -> Array:
	if _moveable_tiles == null or _moveable_tiles.size()==0:
		calculate_moveable_tiles()
	return _moveable_tiles
	
func calculate_moveable_tiles():
	_moveable_tiles = unit_data.move_action.get_targetable_tiles(self, current_tile)

func clear_movement():
	_moveable_tiles.clear()

func get_attackable_tiles(tile: MapTile = current_tile) -> Array:
	return unit_data.attack_action.get_targetable_tiles(self, tile)

func move_to(tile: MapTile):
	var original_position = position
	var target_position = tile.coordinate * 128
	var t = 0
	var move_time = .2
	while position != target_position and t < 1:
		await get_tree().process_frame
		t += get_physics_process_delta_time() / move_time
		position = original_position.lerp (target_position, t)
	print("Move done")

func attack(target):
	await unit_data.attack_action.resolve_action(self, current_tile, target)
	can_move = false
	can_attack = false
	if is_player_unit:
		BattleMap.instance.on_player_attack_resolved()

func apply_damage(amount, source: BattleUnit):
	var damage = amount
	damage = max(0, damage)
	current_health -= damage
	on_health_changed(0)
	DamageText.display_damage_text(damage, self.position)
	AudioPlayer.instance.play_effect(hit_sound)
	if current_health <= 0:
		AudioPlayer.instance.play_effect(death_sound)
		current_unit_stacks -= 1
		current_health = get_stat("max_health")
		on_health_changed(0)
		await source.award_exp(get_stat('exp_value'))
		if not is_player_unit:
			BattleMap.instance.points += get_stat("exp_value")
			BattleMap.instance.point_counter.text = str(BattleMap.instance.points)
		
		if current_unit_stacks <= 0:
			BattleMap.instance.resolve_unit_death(self)

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
	var a_tiles = get_attackable_tiles(current_tile)
	var m_tiles = get_moveable_tiles()
	
	#Check if base is in attack range
	var t = a_tiles.filter(func(t): return t.occupant.is_base).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await attack(t)
		return
	
	#Check if a player unit is in attack range
	t = a_tiles.filter(func(t): return t.occupant.is_player_unit).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await attack(t)
		return
	
	#Check if can move to a tile within range of the base
	t = m_tiles.filter(func(t): return get_attackable_tiles(t).filter(func(t2): return t2.occupant.is_base).front()).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await unit_data.move_action.resolve_action(self, current_tile, t)
		var target = get_attackable_tiles(t).filter(func(t2): return t2.occupant.is_base).front()
		if target != null:
			await get_tree().create_timer(.1).timeout
			await attack(target)
		return
	
	#Check if can move to a tile within range of the player
	t = m_tiles.filter(func(t): return get_attackable_tiles(t).filter(func(t2): return t2.occupant!=null and t2.occupant.is_player_unit).front()).front()
	if t != null:
		await get_tree().create_timer(.1).timeout
		await unit_data.move_action.resolve_action(self, current_tile, t)
		var target = get_attackable_tiles(t).filter(func(t2): return t2.occupant!=null and t2.occupant.is_player_unit).front()
		if target != null:
			await get_tree().create_timer(.1).timeout
			await attack(target)
		return
		
	#Otherwise move as close as possible to the base
	var base_pos = BattleMap.instance.player_base.current_tile.coordinate
	t = m_tiles.reduce(func(max, val): return val if is_closer(val.coordinate, max.coordinate, base_pos) else max, current_tile)
	if t != null:
		await get_tree().create_timer(.1).timeout
		await unit_data.move_action.resolve_action(self, current_tile, t)
		var target = get_attackable_tiles(t).filter(func(t2): return t2.occupant!=null and t2.occupant.is_player_unit).front()
		if target != null:
			await get_tree().create_timer(.1).timeout
			await attack(target)
		return

func is_closer(a,b, target) -> bool:
	return a.distance_to(target) <= b.distance_to(target)

func on_health_changed(amount):
	$HealthLabel.text = str(current_health)
	$StackLabel.text = str("x", current_unit_stacks)
	$StackLabel.visible = (current_unit_stacks != 1)

func is_valid_upgrade(u) -> bool:
	if u._required_tag == "":
		return true
	elif not unit_data._tag_list.has(u._required_tag):
		return false
		
	return true

func update_sprite():
	$UnitSprite.texture = unit_data.unit_sprite

func get_defense_action():
	return load("res://resources/battle actions/default_attack.tres")
