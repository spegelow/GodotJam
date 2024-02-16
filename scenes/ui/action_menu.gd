extends Control

class_name ActionMenu

static var instance: ActionMenu

var actions

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func setup_action_menu(unit: BattleUnit):
	actions = unit.get_actions()
	
	
	$PanelContainer/HBoxContainer/Button1.visible = false
	$PanelContainer/HBoxContainer/Button2.visible = false
	$PanelContainer/HBoxContainer/Button3.visible = false
	$PanelContainer/HBoxContainer/Button4.visible = false

	
	match actions.size():
		0:
			return
		1:
			$PanelContainer/HBoxContainer/Button1.visible = true
			$PanelContainer/HBoxContainer/Button1.text = actions[0].get_action_name()
		2:
			$PanelContainer/HBoxContainer/Button1.visible = true
			$PanelContainer/HBoxContainer/Button1.text = actions[0].get_action_name()
			$PanelContainer/HBoxContainer/Button2.visible = true
			$PanelContainer/HBoxContainer/Button2.text = actions[1].get_action_name()
		3:
			$PanelContainer/HBoxContainer/Button1.visible = true
			$PanelContainer/HBoxContainer/Button1.text = actions[0].get_action_name()
			$PanelContainer/HBoxContainer/Button2.visible = true
			$PanelContainer/HBoxContainer/Button2.text = actions[1].get_action_name()
			$PanelContainer/HBoxContainer/Button3.visible = true
			$PanelContainer/HBoxContainer/Button3.text = actions[2].get_action_name()
		4:
			$PanelContainer/HBoxContainer/Button1.visible = true
			$PanelContainer/HBoxContainer/Button1.text = actions[0].get_action_name()
			$PanelContainer/HBoxContainer/Button2.visible = true
			$PanelContainer/HBoxContainer/Button2.text = actions[1].get_action_name()
			$PanelContainer/HBoxContainer/Button3.visible = true
			$PanelContainer/HBoxContainer/Button3.text = actions[2].get_action_name()
			$PanelContainer/HBoxContainer/Button4.visible = true
			$PanelContainer/HBoxContainer/Button4.text = actions[3].get_action_name()
		
	self.visible = true

func hide_menu():
	self.visible = false

func button_pressed(i):
	PlayerInputManager.instance.action_selected(actions[i])
