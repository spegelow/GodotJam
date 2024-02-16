extends BattleAction

class_name DeployAction

@export_group("Deploy Values")
@export var unit_to_deploy: UnitData
@export var spawn_level: int = 0
@export var modifiers: Array[UnitModifier] = []

func resolve_action(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	pay_cost(user, user_location)
	print(str("Resolving action:", get_action_name(), " used by ", user.unit_data._unit_name, " at ", user_location.coordinate, " targetting ", target_location.coordinate))
	await user.get_tree().create_timer(.1).timeout
	#Spawn the unit at the target location
	var u = BattleMap.instance.create_unit(unit_to_deploy, target_location)
	u.current_level = spawn_level
	for m in modifiers:
		u.modifiers.append(m)
		if m._stat_name == 'max_health':
			u.current_health += m._added_amount
			u.on_health_changed(0)
	await user.get_tree().create_timer(.1).timeout
