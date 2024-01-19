extends Node

class_name UpgradePool

static var pool: UpgradePool

@export var upgrades: Array[UnitModifier]

# Called when the node enters the scene tree for the first time.
func _ready():
	pool = self
	
	

func get_random_upgrade() -> UnitModifier:
	return upgrades.pick_random()
	
