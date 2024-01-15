extends Node2D

class_name BattleMap

@onready var map_width: int = 13
@onready var map_height: int = 13

var tiles : Array
var units : Array

@export var data_template: UnitData
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
	
	var u2 = BattleUnit.build_unit(data_template, get_map_tile(5,5))
	units.append(u2)
	add_child(u2)

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
