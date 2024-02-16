extends Control

class_name UnitInfoPanel

func _on_unit_selected(unit: BattleUnit):
	show_panel(true)
	update_panel(unit)

func _on_unit_deselected(unit: BattleUnit):
	show_panel(true)
	update_panel(unit)

func _on_unit_hovered(unit: BattleUnit):
	show_panel(true)
	update_panel(unit)

func _on_nothing_hovered():
	show_panel(false)

func show_panel(state):
	visible = state

func update_panel(unit: BattleUnit):
	$Panel/VBoxContainer/PanelContainer/NameLabel.text = unit.get_stat('unit_name')
	$Panel/VBoxContainer/PanelContainer/LevelLabel.text = str(unit.current_level)
	$Panel/VBoxContainer/VBoxContainer/StatHealth/Value.text = str(unit.current_health,"/",unit.get_stat('max_health'))
	$Panel/VBoxContainer/VBoxContainer/StatExp/Value.text = str(unit.current_exp,"/",unit.exp_per_level)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatAttack/Value.text = str(unit.get_stat('attack'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatDefense/Value.text = str(unit.get_stat('defense'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatMovement/Value.text = str(unit.get_stat('movement'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatRange/Value.text = str(unit.get_stat('range'))
