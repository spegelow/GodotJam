extends BattleAction

class_name TestAction

func resolve_action(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	pay_cost(user, user_location)
	print(str("Resolving action:", get_action_name(), " used by ", user.unit_data._unit_name, " at ", user_location.coordinate, " targetting ", target_location.coordinate))
	await user.get_tree().create_timer(.1).timeout
	var attack_count = user.get_stat("number_attacks") * user.current_unit_stacks
	var unit = target_location.occupant
	for i in range(0, attack_count):
		if is_instance_valid(unit):
			#Visual FX
			#TODO
			#Sound FX
			AudioPlayer.instance.play_effect(user.attack_sound)
			await unit.apply_damage(user.get_stat('attack'), user)
			await user.get_tree().create_timer(.1).timeout
		
	pass
