extends Node2D

class_name MapTile

const TILE_SCENE = preload("res://scenes/map_tile.tscn")
const TILE_SIZE = 128

var coordinate: Vector2

var neighbors: Array

var occupant: BattleUnit

@onready var tile_sprite: Sprite2D = get_node("TileSprite")
@onready var highlight_sprite: Sprite2D = get_node("HighlightSprite")
@onready var highlight_poly: Polygon2D = get_node("Polygon2D")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Set tile coordinate and adjust position of sprite to match
func position_tile(x,y):
	coordinate = Vector2(x,y)
	position = coordinate * TILE_SIZE

func add_neighbor(other_tile: MapTile):
	if(neighbors == null):
		neighbors = []
	if(other_tile.neighbors == null):
		other_tile.neighbors = []
	if(not neighbors.has(other_tile) and not other_tile.neighbors.has(self)):
		neighbors.append(other_tile)
		other_tile.neighbors.append(self)

func get_neighbors():
	return neighbors

func clear_highlight():
	highlight_poly.visible = false

func set_highlight(color: Color):
	highlight_poly.visible = true
	highlight_poly.color = color

# Instantiate and initialize a new map tile with given params, then hand it back to the caller
static func build_tile(x: int, y: int) -> MapTile:
	var instance: MapTile = TILE_SCENE.instantiate()
	instance.position_tile(x,y)
	return instance

func get_defense_bonus() -> int:
	var data:TileData = BattleMap.instance.tilemap.get_cell_tile_data(0, coordinate)
	return data.get_custom_data("defense")
	
func get_movement_cost(unit: BattleUnit) -> int:
	var data:TileData = BattleMap.instance.tilemap.get_cell_tile_data(0, coordinate)
	return data.get_custom_data("move_cost")

func get_(unit: BattleUnit) -> int:
	var data:TileData = BattleMap.instance.tilemap.get_cell_tile_data(0, coordinate)
	return data.get_custom_data("move_cost")

func can_pass(unit: BattleUnit) -> bool:
	var data:TileData = BattleMap.instance.tilemap.get_cell_tile_data(0, coordinate)
	if data.get_custom_data("impassable"):
		return false
		
	return occupant == null or occupant.is_player_unit==unit.is_player_unit

func can_occupy(unit: BattleUnit) -> bool:
	return occupant == null
