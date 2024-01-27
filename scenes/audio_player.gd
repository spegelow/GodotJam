extends Node

class_name AudioPlayer

static var instance: AudioPlayer

func _ready():
	instance = self
	
func play_effect(stream):
	$AudioStreamPlayer.stream = stream
	$AudioStreamPlayer.play()
