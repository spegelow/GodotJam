extends Control

class_name UnitInfoPanel

func _on_unit_selected(unit: BattleUnit):
	show_panel(true)
	$Panel/VBoxContainer/PanelContainer/NameLabel.text = unit.get_stat('unit_name')
	$Panel/VBoxContainer/VBoxContainer/StatHealth/Value.text = str(unit.current_health,"/",unit.get_stat('max_health'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatAttack/Value.text = str(unit.get_stat('attack'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatDefense/Value.text = str(unit.get_stat('defense'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatMovement/Value.text = str(unit.get_stat('movement'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatRange/Value.text = str(unit.get_stat('range'))

func _on_unit_hovered(unit: BattleUnit):
	show_panel(true)
	$Panel/VBoxContainer/PanelContainer/NameLabel.text = unit.get_stat('unit_name')
	$Panel/VBoxContainer/VBoxContainer/StatHealth/Value.text = str(unit.current_health,"/",unit.get_stat('max_health'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatAttack/Value.text = str(unit.get_stat('attack'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatDefense/Value.text = str(unit.get_stat('defense'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatMovement/Value.text = str(unit.get_stat('movement'))
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatRange/Value.text = str(unit.get_stat('range'))

func show_panel(state):
	visible = state
