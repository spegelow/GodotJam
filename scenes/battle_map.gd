extends Node2D

class_name BattleMap

@onready var map_width: int = 13
@onready var map_height: int = 13

var tiles : Array
var units : Array

var player_base

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
	var u1 = BattleUnit.build_unit(data_template, get_map_tile(2,3))
	units.append(u1)
	add_child(u1)
	u1 = BattleUnit.build_unit(data_template, get_map_tile(3,3))
	units.append(u1)
	add_child(u1)
	
	var u2 = BattleUnit.build_enemy_unit(enemy_data_template, get_map_tile(5,5))
	units.append(u2)
	add_child(u2)
	u2 = BattleUnit.build_enemy_unit(enemy_data_template, get_map_tile(10,10))
	units.append(u2)
	add_child(u2)
	u2 = BattleUnit.build_enemy_unit(enemy_data_template, get_map_tile(1,1))
	units.append(u2)
	add_child(u2)
	
	#Let's create the player base
	player_base = BattleUnit.build_base(base_data_template, get_map_tile(6,6))
	add_child(player_base)
	
	#Let's start the player turn
	start_player_turn()

func start_player_turn():
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
			print("Enemy turn")
			u.resolve_enemy_turn()
	
	start_player_turn()


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
