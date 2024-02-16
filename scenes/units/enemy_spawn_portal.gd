extends Node2D

class_name EnemySpawnPortal


const SCENE = preload("res://scenes/units/enemy_spawn_portal.tscn")
var enemies_to_spawn: Array
var tile: MapTile

var spawner_level: int
var modifiers: Array[UnitModifier]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func try_spawn_next():
	if enemies_to_spawn.size() != 0 and tile.occupant == null:
		var next = enemies_to_spawn.pop_front()
		var u = BattleMap.instance.create_enemy_unit(next, tile)
		u.current_level = spawner_level
		for m in modifiers:
			u.modifiers.append(m)
			if m._stat_name == 'max_health':
				u.current_health += m._added_amount
				u.on_health_changed(0)
		adjust_count()
		await get_tree().create_timer(.05).timeout


# Instantiate and initialize a new spawner with given params, then hand it back to the caller
static func build_spawner(tile: MapTile, scale = 128) -> EnemySpawnPortal:
	var instance: EnemySpawnPortal = SCENE.instantiate()
	instance.tile = tile
	instance.position = tile.coordinate * scale
	
	instance.enemies_to_spawn = []
	
	return instance

func adjust_count():
	$SpawnLabel.text = str(enemies_to_spawn.size())
