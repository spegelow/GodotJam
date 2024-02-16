extends BattleAction

class_name CombatAction

@export var attack_modifier = 0
@export var defense_modifier = 0
@export var speed_modifier = 0

func resolve_action(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	pay_cost(user, user_location)
	print(str("Resolving action:", get_action_name(), " used by ", user.unit_data._unit_name, " at ", user_location.coordinate, " targetting ", target_location.coordinate))
	await user.get_tree().create_timer(.1).timeout
	#Trigger combat so let's pass control to the combat handler???
	await CombatManager.instance.resolve_combat(user,self,target_location.occupant, target_location.occupant.get_defense_action())

func get_action_speed(user: BattleUnit, target: BattleUnit)-> int:
	return user.get_stat('speed') + speed_modifier
