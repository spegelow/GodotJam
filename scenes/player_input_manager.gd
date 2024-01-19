extends Node

class_name PlayerInputManager

signal unit_selected(unit)
signal unit_deselected(unit)
signal destination_clicked(tile)
signal target_clicked(unit)

signal unit_hovered(unit)
signal nothing_hovered(unit)

var current_unit

func _input(event):
	# Mouse click
	if event is InputEventMouseButton and event.is_pressed():
		var tile = BattleMap.map.get_map_tile_from_world_position(event.position)
		if tile != null:
			_on_tile_clicked(tile)
		#print("Mouse Click/Unclick at: ", event.position)
		#print("Tile coordinate: ", BattleMap.map.get_map_tile_from_world_position(event.position))
	# Mouse move
	elif event is InputEventMouseMotion:
		var tile = BattleMap.map.get_map_tile_from_world_position(event.position)
		if tile != null:
			_on_tile_hovered(tile)

func _on_tile_clicked(tile: MapTile):
	if current_unit == null:
		if tile.occupant != null and (tile.occupant.can_move or tile.occupant.can_attack):
			current_unit = tile.occupant
			_on_unit_selected(tile.occupant)
	else:
		if tile.occupant == current_unit:
			current_unit = null
			_on_unit_deselected(tile.occupant)
		elif tile.occupant == null:
			_on_empty_tile_clicked(tile)
			if current_unit.can_move and current_unit.get_moveable_tiles().has(tile):
				await current_unit.move_to(tile)
		else:
			_on_occupied_tile_clicked(tile.occupant)
			if current_unit.can_attack and current_unit.get_attackable_tiles().has(tile):
				await current_unit.attack(tile.occupant)
				current_unit = null

func _on_tile_hovered(tile: MapTile):
	if tile.occupant != null:
		unit_hovered.emit(tile.occupant)
	else:
		nothing_hovered.emit()

func _on_unit_selected(unit):
	print("Unit selected")
	unit_selected.emit(unit)

func _on_unit_deselected(unit):
	print("Unit deselected")

func _on_empty_tile_clicked(tile):
	print("Unit moved")

func _on_occupied_tile_clicked(unit):
	print("Unit attacked")
