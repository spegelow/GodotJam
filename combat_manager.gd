extends Node

class_name CombatManager

static var instance: CombatManager

# Called when the node enters the scene tree for the first time.
func _ready():
	instance = self

func resolve_combat(attacker, attacker_action, defender, defender_action):
	#On combat triggered, launch screen?
	
	#Determine attack order and resolve
	if attacker_action.get_action_speed(attacker, defender) >= defender_action.get_action_speed(defender, attacker):
		#Attacker goes first
		if is_instance_valid(defender):
			await resolve_attack(attacker, attacker_action, defender, defender_action)
		await get_tree().create_timer(.5).timeout
		if is_instance_valid(defender):
			await resolve_attack(defender, defender_action, attacker, attacker_action)
	else:
		#Defender is first
		if is_instance_valid(attacker):
			await resolve_attack(defender, defender_action, attacker, attacker_action)
		await get_tree().create_timer(.5).timeout
		if is_instance_valid(attacker):
			await resolve_attack(attacker, attacker_action, defender, defender_action)
	
	#Should we check for deaths and such here?
	#TODO Handle deaths here, at least exp and such and mark units for death, then the battle manager can clean them up at the correct time

func resolve_attack(attacker, attacker_action, defender, defender_action):
	var attack_count = attacker.get_stat("number_attacks")
	var damage
	for i in range(0, attack_count):
		if is_instance_valid(defender):
			#Visual FX
			#TODO
			#Sound FX
			AudioPlayer.instance.play_effect(attacker.attack_sound)
			damage = attacker.get_stat('attack') - defender.get_stat('defense')
			await defender.apply_damage(damage, attacker)
			await get_tree().create_timer(.1).timeout
