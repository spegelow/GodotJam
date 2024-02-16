extends BattleAction

class_name MoveAction

func resolve_action(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	pay_cost(user, user_location)
	print(str("Resolving action:", get_action_name(), " used by ", user.unit_data._unit_name, " at ", user_location.coordinate, " targetting ", target_location.coordinate))
	await user.get_tree().create_timer(.1).timeout
	
	await user.move_to(target_location)
	user.current_tile.occupant = null
	user.current_tile = target_location
	target_location.occupant = user
	#user.position = target_location.coordinate * 128
	user.can_move = false
