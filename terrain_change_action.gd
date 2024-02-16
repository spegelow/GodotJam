extends BattleAction

class_name TerrainChangeAction

@export var terrain_index: int = 0

func resolve_action(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	pay_cost(user, user_location)
	print(str("Resolving action:", get_action_name(), " used by ", user.unit_data._unit_name, " at ", user_location.coordinate, " targetting ", target_location.coordinate))
	await user.get_tree().create_timer(.1).timeout
	BattleMap.instance.tilemap.set_cell(0, target_location.coordinate, 0, Vector2i(0,0), terrain_index)
