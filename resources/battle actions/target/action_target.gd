extends Resource

class_name ActionTarget

@export var can_target_empty: bool = false
@export var can_target_self: bool = false
@export var can_target_allies: bool = false
@export var can_target_enemies: bool = true
@export var can_target_structures: bool = true

func is_valid_target(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	if user_location == target_location:
		if can_target_self:
			return true
		else:
			return false
	
	if target_location.occupant == null:
		if can_target_empty:
			return true
		else:
			return false
	else:
		if target_location.occupant.is_base and not can_target_structures:
			return false
		if target_location.occupant.is_player_unit == user.is_player_unit:
			if can_target_allies:
				return true
		else:
			if can_target_enemies:
				return true
	
	return false
