extends ActionRange

class_name MovementRange

func get_tiles_in_range(user: BattleUnit, user_location: MapTile) -> Array[MapTile]:
	var move = user.get_stat('movement')
	
	var g_score = {user_location : 0}
	var tile_queue = [user_location]
	
	var moveable: Array[MapTile] = []
	#moveable.append(user_location)
	while tile_queue.size() != 0:
		var t = tile_queue.pop_front()
		
		var neighbors = t.get_neighbors()
		for n in neighbors:
			if n.can_pass(user):
				var new_score = g_score[t] + n.get_movement_cost(user)
				if new_score <= move:
					if g_score.get(n) == null:
						g_score[n] = new_score
						tile_queue.append(n)
						if n.can_occupy(user):
							moveable.append(n)
					elif g_score[n] > new_score:
						g_score[n] = new_score
						tile_queue.append(n)
	return moveable
