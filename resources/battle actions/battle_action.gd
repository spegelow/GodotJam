extends Resource

class_name BattleAction

@export_group("Base Variables")
@export var _action_name: String
@export var _action_icon: Texture2D

@export_group("Action Parameters")
@export var range: ActionRange
@export var cost: ActionCost
@export var target: ActionTarget

func resolve_action(user: BattleUnit, user_location: MapTile, target_location: MapTile):
	pass

func can_afford_cost(user: BattleUnit, user_location: MapTile) -> bool:
	return cost.can_afford_cost(user, user_location)

func pay_cost(user: BattleUnit, user_location: MapTile):
	cost.pay_cost(user, user_location)

func get_targetable_tiles(user: BattleUnit, user_location: MapTile) -> Array[MapTile]:
	return get_tiles_in_range(user, user_location).filter(func(t): return is_valid_target(user, user_location, t))

func is_valid_target(user: BattleUnit, user_location: MapTile, target_location: MapTile) -> bool:
	return target.is_valid_target(user, user_location, target_location)

func get_tiles_in_range(user: BattleUnit, user_location: MapTile) -> Array[MapTile]:
	return range.get_tiles_in_range(user, user_location)

func get_action_name():
	return _action_name
func get_action_icon():
	return _action_icon
