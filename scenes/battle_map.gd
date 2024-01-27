extends Node2D

class_name BattleMap

@onready var map_width: int = 13
@onready var map_height: int = 13

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
var wave_num: int = 0
var points: int = 0

static var map: BattleMap

# Called when the node enters the scene tree for the first time.
func _ready():
	create_dev_map()
	turn_counter.text = str(current_round)
	wave_counter.text = str(wave_num)
	point_counter.text = str(points)
	map = self
	
	$AudioStreamPlayer.play(.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

#Create a map to use for testing in development
func create_dev_map():
	#Let's generate the basic empty map
	generate_map()
	
	#Let's create units and place them
	units = []
	var u = create_player_unit(data_templates[0], get_map_tile(2,3))
	u = create_player_unit(data_templates[1], get_map_tile(3,3))
	u = create_player_unit(data_templates[2], get_map_tile(4,3))
	
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
	turn_counter.text = str(current_round)
	for u in units:
		if u.is_player_unit:
			u.can_move = true
			u.can_attack = true
	PlayerInputManager.manager.can_process_clicks = true
	end_turn.visible = true

func end_player_turn():
	for u in units:
		if u.is_player_unit:
			u.can_move = false
			u.can_attack = false
	end_turn.visible = false
	PlayerInputManager.manager.can_process_clicks = false
	resolve_enemy_turn()

func resolve_enemy_turn():
	
	#Show Enemy Turn Splash
	enemy_turn.visible = true
	
	for u in units:
		if not u.is_player_unit:
			highlight_tiles([u.current_tile],Color.RED)
			await u.resolve_enemy_turn()
			reset_highlighting()
	
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
	
	#Hide enemy turn splash
	enemy_turn.visible = false
	
	if not units.any(func(u): return u.is_player_unit) or player_base.current_health <= 0:
			resolve_loss()
	else:
		start_player_turn()

func resolve_unit_death(unit):
	if not unit.is_base:
		AudioPlayer.instance.play_effect(unit.death_sound)
		units.erase(unit)
		unit.queue_free()

func resolve_loss():
	get_tree().quit()

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
	else:
		PlayerInputManager.manager.can_process_clicks = true

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
