extends PanelContainer

class_name LevelUpMenu

static var menu: LevelUpMenu

@export var upgrade_panels: Array

@export var upgrades: Array

var leveling_unit

signal menu_closed

# Called when the node enters the scene tree for the first time.
func _ready():
	menu = self
	upgrade_panels = [$HBoxContainer/UpgradePanel1, $HBoxContainer/UpgradePanel2, $HBoxContainer/UpgradePanel3]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func set_up_menu(unit):
	var upgrades = UpgradePool.pool.get_random_upgrade_set(unit)
	leveling_unit = unit
	
	for p in upgrade_panels:
		var u = upgrades.pop_front()
		p.get_node("Name").text = u._mod_name
		p.get_node("Desc").text = u._mod_desc
		p.get_node("Button").pressed.connect(upgrade_chosen.bind(u))
		upgrades.append(u)
	
	visible = true

func upgrade_chosen(u):
	print(u._mod_name)
	leveling_unit.add_upgrade(u)
	leveling_unit = null
	visible = false
	menu_closed.emit()
