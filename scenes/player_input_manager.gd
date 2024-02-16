extends Node

class_name PlayerInputManager

static var instance: PlayerInputManager

var mouse_drag_start

var middle_drag_start

@onready var camera: Camera2D = $Camera2D


func _init():
	instance = self

func _input(event):
   # Mouse in viewport coordinates.
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				handle_left_mouse_click(event)
			MOUSE_BUTTON_RIGHT:
				handle_right_mouse_click(event)
			MOUSE_BUTTON_MIDDLE:
				handle_middle_mouse_click(event)
			MOUSE_BUTTON_WHEEL_UP, MOUSE_BUTTON_WHEEL_DOWN:
				handle_mouse_wheel_scroll(event)
			_:
				if event is InputEventKey and event.is_pressed() and event.keycode == KEY_SPACE:
					BattleManager.instance.end_player_turn()
	elif event is InputEventMouseMotion:
		handle_mouse_movement(event)


func handle_left_mouse_click(event: InputEventMouseButton):
	print("Left Mouse Click/Unclick at: ", camera.get_global_mouse_position())
	var p = get_map_tile_at_position(camera.get_global_mouse_position())
	
	if event.pressed:
		# Mouse was clicked
		mouse_drag_start = p
	else:
		var tile = BattleMap.instance.get_map_tile_from_world_position(event.position)
		if tile != null:
			_on_tile_clicked(tile)
		
#This was for mouse drag selection. Not needed here
#		# Mouse was unclicked
#		var mouse_drag_end = p
#		var selected_tile_range = CombatManager.instance.map.get_tiles_rect(mouse_drag_start, mouse_drag_end)
#		for t in selected_tile_range:
#			if t.tile_type == 0:
#				t.tile_type = 1
#			else:
#				t.tile_type = 0


func handle_right_mouse_click(event: InputEventMouseButton):
	print("Right Mouse Click/Unclick at: ", camera.get_global_mouse_position())
	var p = get_map_tile_at_position(camera.get_global_mouse_position())
	
	CombatManager.instance.actor.target = p


func handle_middle_mouse_click(event: InputEventMouseButton):
	print("Middle Mouse Click/Unclick at: ", camera.get_global_mouse_position())
	
	back_pressed()


func handle_mouse_movement(event: InputEventMouseMotion):
	print("Mouse Motion at: ", camera.get_global_mouse_position())
	
	var tile = BattleMap.instance.get_map_tile_from_world_position(event.position)
	if tile != null:
		_on_tile_hovered(tile)
	
	# If the middle mouse button was held down, dragging the mouse should move the camera
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		# Move the camera?
		camera.position -= event.relative / camera.zoom.x


func handle_mouse_wheel_scroll(event: InputEventMouseButton):
	print("Mouse wheel scroll")
	
	if event.button_index == MOUSE_BUTTON_WHEEL_UP:
		camera.zoom += Vector2(.1,.1)
	elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
		camera.zoom -= Vector2(.1,.1)


func get_map_tile_at_position(position) -> Vector2i:
	# Adding scale / 2 as tiles are based on their center
	var x = (position.x + BattleMap.instance.map_scale/2) / BattleMap.instance.map_scale as int
	var y = (position.y + BattleMap.instance.map_scale/2) / BattleMap.instance.map_scale as int
	
	return Vector2i(x,y)




































signal unit_selected(unit)
signal unit_deselected(unit)
signal destination_clicked(tile)
signal target_clicked(unit)
signal unit_hovered(unit)
signal nothing_hovered(unit)

var current_unit: BattleUnit
var current_action: BattleAction
var can_process_clicks = true

enum InputState {
	UNIT_SELECTION,
	ACTION_SELECTION,
	TARGET_SELECTION
}

var state: InputState = InputState.UNIT_SELECTION

func _on_tile_clicked(tile: MapTile):
	match state:
		InputState.UNIT_SELECTION:
			#Select the unit on this tile
			if tile.occupant != null and (tile.occupant.can_move or tile.occupant.can_attack):
				current_unit = tile.occupant
				state = InputState.ACTION_SELECTION
				ActionMenu.instance.setup_action_menu(current_unit)
				_on_unit_selected(tile.occupant)
			#Should we open a menu or something otherwise
			return
		InputState.ACTION_SELECTION:
			#They might be trying to move, check if they can move and if the tile they clicked is movable, if so move them
			if current_unit.can_move:
				if current_unit.get_moveable_tiles().has(tile):
					can_process_clicks = false
					await current_unit.unit_data.move_action.resolve_action(current_unit, current_unit.current_tile, tile)
					BattleMap.instance.reset_highlighting()
					current_unit.current_tile.set_highlight(Color.LIME_GREEN)
					select_highlight(current_unit)
					can_process_clicks = true
			return
		InputState.TARGET_SELECTION:
			#Deselect the current action
			state = InputState.ACTION_SELECTION
			if current_unit.can_attack and current_action.get_targetable_tiles(current_unit, current_unit.current_tile).has(tile):
				BattleMap.instance.reset_highlighting()
				can_process_clicks = false
				await current_unit.attack(tile)
				try_deselect()
				ActionMenu.instance.hide_menu()
				state = InputState.UNIT_SELECTION
				current_action = null
			return

func try_deselect():
	#If no unit is selected we can't deselect them
	if current_unit == null:
		return

	_on_unit_deselected(current_unit)
	current_unit = null

func back_pressed():
	match state:
		InputState.UNIT_SELECTION:
			#Nothing is selected so do nothing here
			#TODO Open menu???
			return
		InputState.ACTION_SELECTION:
			#Let's deselect the unit and clear highlighting
			BattleMap.instance.reset_highlighting()
			select_highlight(current_unit)
			try_deselect()
			state = InputState.UNIT_SELECTION
			ActionMenu.instance.hide_menu()
			return
		InputState.TARGET_SELECTION:
			#Deselect the current action
			state = InputState.ACTION_SELECTION
			ActionMenu.instance.setup_action_menu(current_unit)
			current_action = null
			BattleMap.instance.reset_highlighting()
			select_highlight(current_unit)

			return

func action_selected(action: BattleAction):
	current_action = action
	state = InputState.TARGET_SELECTION
	ActionMenu.instance.hide_menu()
	BattleMap.instance.reset_highlighting()
	current_unit.current_tile.set_highlight(Color.LIME_GREEN)
	select_highlight(current_unit)


func _on_tile_hovered(tile: MapTile):
	if tile.occupant != null:
		unit_hovered.emit(tile.occupant)
	else:
		nothing_hovered.emit()

	if current_unit == null:
		$Cursor.position = tile.position


func _on_unit_selected(unit):
	print("Unit selected")
	unit_selected.emit(unit)
	select_highlight(unit)


func _on_unit_deselected(unit):
	print("Unit deselected")
	unit_deselected.emit(unit)
	unit.clear_movement()


func select_highlight(unit):
	current_unit.current_tile.set_highlight(Color.LIME_GREEN)
	#Display move range & attack range
	if unit.can_move and current_action == null:
		var m_tiles = unit.get_moveable_tiles()
		BattleMap.instance.highlight_tiles(m_tiles, Color.GREEN)
	elif unit.can_attack and current_action != null:
		var r_tiles = current_action.get_tiles_in_range(current_unit, current_unit.current_tile)
		var a_tiles = current_action.get_targetable_tiles(current_unit, current_unit.current_tile)
		current_unit.current_tile.set_highlight(Color.LIME_GREEN)
		BattleMap.instance.highlight_tiles(r_tiles, Color.ORANGE_RED)
		BattleMap.instance.highlight_tiles(a_tiles, Color.RED)
