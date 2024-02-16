extends Node2D

class_name BattleMap


# Get all tiles whose x and y coordinates fall in the given ranges (inclusive)
func get_tile_rect(p1: Vector2i, p2: Vector2i) -> Array[MapTile]:
	var tile_range: Array[MapTile]
	
	for x in range(min(p1.x,p2.x),max(p1.x,p2.x)+1):
		for y in range(min(p1.y,p2.y),max(p1.y,p2.y)+1):
			tile_range.append(get_map_tile(x,y))
	
	return tile_range
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	

@onready var map_width: int = 13
@onready var map_height: int = 13
@onready var map_scale: int = 128

var tiles : Array
var units : Array
var spawners : Array

var player_base

var current_round

@export var data_templates: Array[UnitData]
@export var base_data_template: UnitData

@onready var end_turn = get_node("../EndTurn")
@onready var enemy_turn = get_node("../EnemyTurn")
@onready var turn_counter = get_node("../PanelContainer/VBoxContainer/Turn/Val")
@onready var wave_counter = get_node("../PanelContainer/VBoxContainer/Wave/Val")
@onready var point_counter = get_node("../PanelContainer/VBoxContainer/Points/Val")

var points: int = 0

@onready var tilemap: TileMap = $TileMap

static var instance: BattleMap

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Create a map to use for testing in development
func create_dev_map():
	#Let's generate the basic empty map
	generate_map()
	
	#Let's create units and place them
	units = []
	var u = create_player_unit(data_templates[0], get_map_tile(5,5))
	u = create_player_unit(data_templates[1], get_map_tile(6,5))
	u = create_player_unit(data_templates[2], get_map_tile(7,5))
	
	#Let's create the player base
	create_player_base(base_data_template, get_map_tile(6,6))
	
	#Let's create a few spawners
	spawners = []
	
	turn_counter.text = str(current_round)
	wave_counter.text = str(1)
	point_counter.text = str(points)
	
	$AudioStreamPlayer.play(.1)

func create_unit(data: UnitData, tile: MapTile, is_player:bool = true) -> BattleUnit:
	var u = BattleUnit.build_unit(data, tile)
	u.is_player_unit = is_player
	units.append(u)
	add_child(u)
	return u

func create_player_unit(data: UnitData, tile: MapTile) -> BattleUnit:
	return create_unit(data, tile, true)

func create_enemy_unit(data: UnitData, tile: MapTile) -> BattleUnit:
	return create_unit(data, tile, false)

func create_player_base(data: UnitData, tile: MapTile) -> BattleUnit:
	var u = BattleUnit.build_base(data, tile)
	player_base = u
	add_child(u)
	return u

func start_player_turn():
	current_round += 1
	turn_counter.text = str(current_round)
	for u in units:
		if u.is_player_unit:
			u.can_move = true
			u.can_attack = true
	PlayerInputManager.instance.can_process_clicks = true
	end_turn.visible = true

func resolve_unit_death(unit):
	if not unit.is_base:
		units.erase(unit)
		unit.queue_free()

func resolve_loss():
	BattleManager.instance.end_combat()

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

func get_tiles_in_range(origin: MapTile, range: int, min_range: int = 0) -> Array[MapTile]:
	var tiles_in_range: Array[MapTile] = []
	var current_range: int
	for y_diff in range(-range, range+1):
		for x_diff in range(-range, range+1):
			current_range = abs(x_diff) + abs(y_diff)
			if current_range <= range and current_range >= min_range:
				var t = get_map_tile_vector2D(origin.coordinate + Vector2(x_diff,y_diff))
				if t != null:
					tiles_in_range.append(t)
	return tiles_in_range

func on_player_attack_resolved():
	if not units.any(func(u): return u.can_attack and u.is_player_unit):
		BattleManager.instance.end_player_turn()
	else:
		PlayerInputManager.instance.can_process_clicks = true

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

func reset_highlighting():
	for t in tiles:
		t.clear_highlight()

func highlight_tiles(tiles, color):
	for t in tiles:
		t.set_highlight(color)

func _on_player_unit_selected(unit):
	reset_highlighting()
	unit.current_tile.set_highlight(Color.LIME_GREEN)


func _on_player_unit_deselected(unit):
	reset_highlighting()

func grant_points(amt):
	points += amt
	point_counter.text = str(points)
