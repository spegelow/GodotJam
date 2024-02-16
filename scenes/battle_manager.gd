extends Node

class_name BattleManager

const GAME_OVER_SCENE = preload("res://scenes/ui/game_over_panel.tscn")

var current_wave = 1
var rounds_left

static var instance: BattleManager


# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self
	
	
	#Let's start the player turn
	BattleMap.instance.current_round = 0
	BattleMap.instance.create_dev_map()
	
	start_wave()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func start_round():
	#Start the player's turn
	start_player_turn()

func start_player_turn():
	BattleMap.instance.start_player_turn()

func end_player_turn():
	for u in BattleMap.instance.units:
		if u.is_player_unit:
			u.can_move = false
			u.can_attack = false
	BattleMap.instance.end_turn.visible = false
	PlayerInputManager.instance.can_process_clicks = false
	start_enemy_turn()

func start_enemy_turn():
	#Show Enemy Turn Splash
	BattleMap.instance.enemy_turn.visible = true
	resolve_enemy_turn()

func resolve_enemy_turn():
	
	for u in BattleMap.instance.units:
		if not u.is_player_unit:
			BattleMap.instance.highlight_tiles([u.current_tile],Color.RED)
			await u.resolve_enemy_turn()
			BattleMap.instance.reset_highlighting()
			
	if not BattleMap.instance.units.any(func(u): return u.is_player_unit) or BattleMap.instance.player_base.current_health <= 0:
			BattleMap.instance.resolve_loss()
	else:
		BattleManager.instance.end_enemy_turn()

func end_enemy_turn():
	#Trigger any existing spawners
	var to_remove = []
	for s in BattleMap.instance.spawners:
		await s.try_spawn_next()
		if s.enemies_to_spawn.size() == 0:
			to_remove.append(s)
		
	for s in to_remove:
		BattleMap.instance.spawners.erase(s)
		s.queue_free()
	
	#Create new spawners
	EnemySpawnManager.spawn_manager.create_new_spawner()
	
	#Hide enemy turn splash
	BattleMap.instance.enemy_turn.visible = false
	
	end_round()

func end_round():
	rounds_left -= 1
	print(str(rounds_left))
	if(rounds_left > 0):
		start_round()
	else:
		end_wave()

func start_wave():
	#Prepare next wave
	rounds_left = min(5 + current_wave, 20)
	
	#Create next waves enemies
	EnemySpawnManager.spawn_manager.prepare_next_wave(current_wave)
	
	#Set up some initial spawners?
	EnemySpawnManager.spawn_manager.create_new_spawner()
	EnemySpawnManager.spawn_manager.create_new_spawner()
	EnemySpawnManager.spawn_manager.create_new_spawner()
	EnemySpawnManager.spawn_manager.create_new_spawner()
	
	#Place player units?
	#Heal Players?
	#Other stuff?
	start_round()
	pass
	
func end_wave():
	#Clear remaining enemies
	#Give resources?
	#Apply Level ups?
	#Allow buildings
	#Create spawner predictions?
	
	current_wave+=1
	BattleMap.instance.wave_counter.text = str(current_wave)
	start_wave()
	pass

func end_combat():
	#Launch the game over screen
	var node = GAME_OVER_SCENE.instantiate()
	add_child(node)
	
	#Disable all other input TODO
	

func forfeit():
	end_combat()
