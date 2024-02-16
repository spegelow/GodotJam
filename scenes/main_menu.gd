extends Node

class_name MainMenu

const GAME_SCENE = preload("res://scenes/battle_scene.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
#	$Play.pressed.connect(_on_play_pressed)
#	$Quit.pressed.connect(_on_quit_pressed)
	$AudioStreamPlayer.play(.1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_play_pressed():
	var node = GAME_SCENE.instantiate()
	get_tree().root.add_child(node)
	get_node("/root/main_menu").queue_free()

func _on_quit_pressed():
	get_tree().quit()
