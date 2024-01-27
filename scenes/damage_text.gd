extends Label

class_name DamageText

var move_speed = 100
var move_direction = Vector2.UP
var lifespan = 1

const SCENE = preload("res://scenes/damage_text.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += move_direction * move_speed * delta

static func display_damage_text(damage_amount, position):
	var instance: DamageText  = SCENE.instantiate()
	instance.text = str(damage_amount)
	
	instance.position = position
	BattleMap.map.add_child(instance)
	
	await instance.get_tree().create_timer(instance.lifespan).timeout
	
	if is_instance_valid(instance):
		instance.queue_free()
