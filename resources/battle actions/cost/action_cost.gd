extends Resource

class_name ActionCost

@export var amount: int = 0

func can_afford_cost(user: BattleUnit, user_location: MapTile) -> bool:
	#For now pay the cost out of points
	return BattleMap.instance.points >= amount

func pay_cost(user: BattleUnit, user_location: MapTile):
	#For now pay the cost out of points
	BattleMap.instance.points -= amount
	BattleMap.instance.point_counter.text = str(BattleMap.instance.points)
