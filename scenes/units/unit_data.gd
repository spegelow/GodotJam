extends Resource

class_name UnitData

@export var _unit_name = "Default Unit"
@export var _max_health = 10
@export var _attack = 3
@export var _defense = 1
@export var _speed = 3
@export var _movement = 3
@export var _range = 1
@export var _exp_value = 1

@export var _number_attacks = 1
@export var _stack_cap = 1

@export var _tag_list: Array[String] = []

@export var unit_sprite: Texture2D
@export var attack_action: BattleAction
@export var move_action: BattleAction

@export var starting_items: Array[ItemData] = []

func get_stat(stat) -> Variant:
	match stat:
		'unit_name':
			return _unit_name
		'max_health':
			return _max_health
		'attack':
			return _attack
		'defense':
			return _defense
		'movement':
			return _movement
		'range':
			return _range
		'exp_value':
			return _exp_value
		'number_attacks':
			return _number_attacks
		'stack_cap':
			return _stack_cap
		'speed':
			return _speed
		_:
			return 0
