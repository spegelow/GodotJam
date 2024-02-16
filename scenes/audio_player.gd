extends Node

class_name AudioPlayer

static var instance: AudioPlayer

var available_audio_players: Array[AudioStreamPlayer]

func _ready():
	instance = self
	
func play_effect(stream):
	var player = get_available_player()
	player.stream = stream
	player.play()
	available_audio_players.erase(player)
	player.finished.connect(func(): available_audio_players.append(player))

func get_available_player() -> AudioStreamPlayer:
	var player
	if available_audio_players.size() == 0:
		player = AudioStreamPlayer.new()
		add_child(player)
		return player
	else:
		player = available_audio_players[0]
		return player
