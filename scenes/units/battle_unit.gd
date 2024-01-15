extends Node2D

class_name BattleUnit

const UNIT_SCENE = preload("res://scenes/units/battle_unit.tscn")

var isPlayerUnit = true

var unit_data: UnitData

var current_health
var current_tile

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Instantiate and initialize a new unit with given params, then hand it back to the caller
static func build_unit(data: UnitData, tile: MapTile, scale = 128) -> BattleUnit:
	var instance: BattleUnit = UNIT_SCENE.instantiate()
	instance.current_tile = tile
	tile.occupant = instance
	instance.position = tile.coordinate * scale
	
	instance.unit_data = data
	instance.current_health = data.max_health
	
	return instance

func move_to(tile: MapTile, scale = 128):
	current_tile.occupant = null
	current_tile = tile
	tile.occupant = self
	position = tile.coordinate * scale

func attack(unit: BattleUnit):
	unit.apply_damage(unit_data.attack)

func apply_damage(amount):
	current_health -= amount - unit_data.defense
