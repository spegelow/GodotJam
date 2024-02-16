extends Resource

class_name ActionRange

@export var min_range: int = 1
@export var max_range: int = 1

func get_tiles_in_range(user: BattleUnit, user_location: MapTile) -> Array[MapTile]:
	var tiles: Array[MapTile] = BattleMap.instance.get_tiles_in_range(user_location, max_range, min_range)
	return tiles
	
