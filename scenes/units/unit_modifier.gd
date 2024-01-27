extends Resource

class_name UnitModifier

@export_enum('unit_name','max_health','attack','defense','movement','range','exp_value') var _stat_name: String
@export var _added_amount: int

@export var _mod_val: int = 1

@export var _mod_name: String = "Default"
@export var _mod_desc: String = "It does stuff"
@export var _required_tag: String = ""


func modify_stat(stat, val) -> Variant:
	print(str("Modifying ", stat))
	if stat == _stat_name:
		return val + _added_amount
	else:
		return val

func _init(stat ='max_health', amount=0):
	_stat_name = stat
	_added_amount = amount
