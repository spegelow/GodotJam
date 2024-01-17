extends Control

class_name UnitInfoPanel

func _on_unit_selected(unit: BattleUnit):
	$Panel/VBoxContainer/PanelContainer/NameLabel.text = unit.unit_data.unit_name
	$Panel/VBoxContainer/VBoxContainer/StatHealth/Value.text = str(unit.current_health,"/",unit.unit_data.max_health)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatAttack/Value.text = str(unit.unit_data.attack)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatDefense/Value.text = str(unit.unit_data.defense)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatMovement/Value.text = str(unit.unit_data.movement)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatRange/Value.text = str(unit.unit_data.range)

func _on_unit_hovered(unit: BattleUnit):
	$Panel/VBoxContainer/PanelContainer/NameLabel.text = unit.unit_data.unit_name
	$Panel/VBoxContainer/VBoxContainer/StatHealth/Value.text = str(unit.current_health,"/",unit.unit_data.max_health)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatAttack/Value.text = str(unit.unit_data.attack)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatDefense/Value.text = str(unit.unit_data.defense)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatMovement/Value.text = str(unit.unit_data.movement)
	$Panel/VBoxContainer/VBoxContainer/GridContainer/StatRange/Value.text = str(unit.unit_data.range)
