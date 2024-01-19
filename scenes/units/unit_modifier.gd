extends Resource

class_name UnitModifier

@export_enum('unit_name','max_health','attack','defense','movement','range','exp_value') var _stat_name: String
@export var _added_amount: int

func modify_stat(stat, val) -> Variant:
	print(str("Modifying ", stat))
	if stat == _stat_name:
		return val + _added_amount
	else:
		return val

func _init(stat ='max_health', amount=0):
	_stat_name = stat
	_added_amount = amount
