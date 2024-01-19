extends Node2D

class_name BattleMap

@onready var map_width: int = 13
@onready var map_height: int = 13

var tiles : Array
var units : Array
var spawners : Array

var player_base

var current_round

@export var data_template: UnitData
@export var enemy_data_template: UnitData
@export var base_data_template: UnitData

static var map: BattleMap

# Called when the node enters the scene tree for the first time.
func _ready():
	create_dev_map()
	map = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Create a map to use for testing in development
func create_dev_map():
	#Let's generate the basic empty map
	generate_map()
	
	#Let's create units and place them
	units = []
	var u = create_player_unit(data_template, get_map_tile(2,3))
	u = create_player_unit(data_template, get_map_tile(3,3))
	
	#Let's create the player base
	create_player_base(base_data_template, get_map_tile(6,6))
	
	#Let's create a few spawners
	spawners = []
	
	#Let's start the player turn
	current_round = 0
	start_player_turn()


func create_player_unit(data: UnitData, tile: MapTile) -> BattleUnit:
	var u = BattleUnit.build_unit(data, tile)
	units.append(u)
	add_child(u)
	return u

func create_enemy_unit(data: UnitData, tile: MapTile) -> BattleUnit:
	var u = BattleUnit.build_enemy_unit(data, tile)
	units.append(u)
	add_child(u)
	return u

func create_player_base(data: UnitData, tile: MapTile) -> BattleUnit:
	var u = BattleUnit.build_base(data, tile)
	player_base = u
	add_child(u)
	return u

func start_player_turn():
	current_round += 1
	for u in units:
		if u.is_player_unit:
			u.can_move = true
			u.can_attack = true

func end_player_turn():
	for u in units:
		if u.is_player_unit:
			u.can_move = false
			u.can_attack = false
	
	resolve_enemy_turn()

func resolve_enemy_turn():
	for u in units:
		if not u.is_player_unit:
			#print("Enemy turn")
			await u.resolve_enemy_turn()
	
	#Trigger any existing spawners
	var to_remove = []
	for s in spawners:
		await s.try_spawn_next()
		if s.enemies_to_spawn.size() == 0:
			to_remove.append(s)
		
	for s in to_remove:
		spawners.erase(s)
		s.queue_free()
	
	#Create new spawners
	EnemySpawnManager.spawn_manager.create_new_spawner(current_round)
	
	start_player_turn()

func resolve_unit_death(unit):
	if not unit.is_base:
		units.erase(unit)
		unit.queue_free()
		if not units.any(func(u): u.is_player_unit):
			resolve_loss()
	else:
		resolve_loss()

func resolve_loss():
	print("You lose! Git gud!")

func get_map_tile_vector2D(coordinate: Vector2):
	return get_map_tile(coordinate.x, coordinate.y)

func get_map_tile(x: int, y: int):
	if x < 0 or x >= map_width or y < 0 or y >= map_height:
		return null
	return tiles[x + y*map_width]

func get_map_tile_from_world_position(pos: Vector2) -> MapTile:
	var x = pos.x / 128
	var y = pos.y / 128
	return get_map_tile(x, y)

func get_tiles_in_range(origin: MapTile, range: int) -> Array:
	var tiles_in_range = []
	for y_diff in range(-range, range+1):
		for x_diff in range(-range, range+1):
			if abs(x_diff) + abs(y_diff) <= range:
				var t = get_map_tile_vector2D(origin.coordinate + Vector2(x_diff,y_diff))
				if t != null:
					tiles_in_range.append(t)
	return tiles_in_range

func on_player_attack_resolved():
	if not units.any(func(u): return u.can_attack and u.is_player_unit):
		end_player_turn()

func generate_map():
	#Initialize array of tiles
	tiles = []
	var instance: MapTile
	#Loop and create each tile row by row
	for y in range(map_height):
		for x in range(map_width):
			instance = MapTile.build_tile(x, y)
			#Add tiles to the left and above as neighbors as this will get all adjacencies
			var neighbor = get_map_tile(x-1,y)
			if (neighbor != null):
				instance.add_neighbor(neighbor)
			neighbor = get_map_tile(x,y-1)
			if (neighbor != null):
				instance.add_neighbor(neighbor)
			add_child(instance)
			tiles.append(instance)
