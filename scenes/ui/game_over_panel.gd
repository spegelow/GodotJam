extends Control

class_name GameOverPanel

var main_scene

# Called when the node enters the scene tree for the first time.
func _ready():
	main_scene = preload("res://scenes/main_menu.tscn")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_quit_pressed():
	get_tree().quit()


func _on_menu_pressed():
	var node = main_scene.instantiate()
	get_tree().root.add_child(node)
	get_node("/root/game").queue_free()
