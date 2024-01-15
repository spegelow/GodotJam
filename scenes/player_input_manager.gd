extends Node

class_name PlayerInputManager

signal unit_selected(unit)
signal unit_deselected(unit)
signal destination_clicked(tile)
signal target_clicked(unit)

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
	#elif event is InputEventMouseMotion:
	##	print("Mouse Motion at: ", event.position)

func _on_tile_clicked(tile: MapTile):
	if current_unit == null:
		if tile.occupant != null:
			current_unit = tile.occupant
			_on_unit_selected(tile.occupant)
	else:
		if tile.occupant == current_unit:
			current_unit = null
			_on_unit_deselected(tile.occupant)
		elif tile.occupant == null:
			_on_empty_tile_clicked(tile)
			current_unit.move_to(tile)
			current_unit = null
		else:
			_on_occupied_tile_clicked(tile.occupant)
			current_unit.attack(tile.occupant)
			current_unit = null


func _on_unit_selected(unit):
	print("Unit selected")
	unit_selected.emit(unit)

func _on_unit_deselected(unit):
	print("Unit deselected")

func _on_empty_tile_clicked(tile):
	print("Unit moved")

func _on_occupied_tile_clicked(unit):
	print("Unit attacked")
