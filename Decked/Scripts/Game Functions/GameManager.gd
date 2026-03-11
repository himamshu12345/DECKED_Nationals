extends Node

var p1_cards = []
var p2_cards = []
var boss1_cards = []
var boss2_cards = []
var boss3_cards = []
var p1_stats = {
	"health_bonus": 0,
	"damage_bonus": 0,
	"speed_bonus": 0,
	"dashspeed_bonus": 0,
	"dashcooldown_bonus": 0
}
var p2_stats = {
	"health_bonus": 0,
	"damage_bonus": 0,
	"speed_bonus": 0,
	"dashspeed_bonus": 0,
	"dashcooldown_bonus": 0
}
var boss1_stats = {
	"health_bonus": 0,
	"damage_bonus": 0,
	"speed_bonus": 0,
	"dashspeed_bonus": 0,
	"dashcooldown_bonus": 0
}

var boss2_stats = {
	"health_bonus": 0,
	"damage_bonus": 0,
	"speed_bonus": 0,
	"dashspeed_bonus": 0,
	"dashcooldown_bonus": 0
}

var boss3_stats = {
	"health_bonus": 0,
	"damage_bonus": 0,
	"speed_bonus": 0,
	"dashspeed_bonus": 0,
	"dashcooldown_bonus": 0
}

var all_cards = [
	{
		"name": "Hypercalcemia",
		"description": "Adds 30 health",
		"rarity": "COMMON",
		"buff_type": "Health",
		"value": 30.0,
		"icon_path": "res://Decked/Assests/Cards/Hypercalcemia-0003.webp"
	},
	{
		"name": "Thorns",
		"description": "Adds 0.5 Damage",
		"rarity": "RARE",
		"buff_type": "Damage",
		"value": 0.5,
		"icon_path": "res://Decked/Assests/Cards/Thorns.webp"
	},
	{
		"name": "Habanero",
		"description": "Adds 2 Damage",
		"rarity": "LEGENDARY",
		"buff_type": "Damage",
		"value": 2.0,
		"icon_path": "res://Decked/Assests/Cards/Habanero.webp"
	},
	{
		"name": "Vampire",
		"description": "Adds 0.2 Damage",
		"rarity": "UNCOMMON",
		"buff_type": "Damage",
		"value": 0.2,
		"icon_path": "res://Decked/Assests/Cards/Vampire.webp"
	},
	{
		"name": "Sprinting",
		"description": "Adds 15 Movement Speed",
		"rarity": "COMMON",
		"buff_type": "Speed",
		"value": 15.0,
		"icon_path": "res://Decked/Assests/Cards/Sprinting.webp"
	},
	{
		"name": "Bulldozer",
		"description": "Adds 2 damages",
		"rarity": "LEGENDARY",
		"buff_type": "Damage",
		"value": 2.0,
		"icon_path": "res://Decked/Assests/Cards/Bulldozer.webp"
	},
	{
		"name": "Footwork",
		"description": "Dash takes 10% less time to activate",
		"rarity": "COMMON",
		"buff_type": "DashCooldown",
		"value": 0.02,
		"icon_path": "res://Decked/Assests/Cards/Footwork.webp"
	},
	{
		"name": "Ninja",
		"description": "Dash takes 75% less time to activate",
		"rarity": "LEGENDARY",
		"buff_type": "DashCooldown",
		"value": 0.15,
		"icon_path": "res://Decked/Assests/Cards/Ninjawhitewashed.webp"
	}
]

func apply_buff(player_id: int, mod_type: String, value: float):
	var target_stats
	if player_id == 1:
		target_stats = p1_stats
	elif player_id == 2:
		target_stats = p2_stats
	elif player_id == 3:
		target_stats = boss1_stats
	elif player_id == 4:
		target_stats = boss2_stats
	elif player_id == 5:
		target_stats = boss3_stats
	
	match mod_type:
		"Health":
			target_stats["health_bonus"] += value
		"Damage":
			target_stats["damage_bonus"] += value
		"Speed":
			target_stats["speed_bonus"] += value
		"DashSpeed":
			target_stats["dashspeed_bonus"] += value
		"DashCooldown":
			target_stats["dashcooldown_bonus"] += value

func add_card(player_id: int, card_data: Dictionary):
	if player_id == 1:
		p1_cards.append(card_data)
	elif player_id == 2:
		p2_cards.append(card_data)
	elif player_id == 3:
		boss1_cards.append(card_data)
	elif player_id == 4:
		boss2_cards.append(card_data)
	elif player_id == 5:
		boss3_cards.append(card_data)
	else:
		pass

func get_buffs(player_id: int) -> Dictionary:
	if player_id == 1:
		return p1_stats
	elif player_id == 2:
		return p2_stats
	elif player_id == 3:
		return boss1_stats
	elif player_id == 4:
		return boss2_stats
	elif player_id == 5:
		return boss3_stats
	else:
		return {}

func give_boss_random_card(boss):
	if all_cards.size() == 0:
		push_error("No cards available for boss!")
		return
	
	var random_index = randi() % all_cards.size()
	var random_card = all_cards[random_index]
	
	apply_buff(boss, random_card["buff_type"], random_card["value"])
	add_card(boss, random_card)
	
	print(boss, " received card: ", random_card["name"], " (+", random_card["value"], " ", random_card["buff_type"], ")")
	
var current_loser: int = 0 
var rounds := 1
var p1_losses: int = 0
var p2_losses: int = 0
var boss1_losses: int = 0
var boss2_losses: int = 0
var boss3_losses: int = 0

signal score_updated(p1, p2, b1, b2, b3)

func player_died(player_node: Node2D):
	if player_node.name == "Player1":
		current_loser = 1
		p1_losses += 1
	elif player_node.name == "Player2":
		current_loser = 2
		p2_losses += 1
	elif player_node.name == "Boss1":
		current_loser = 3
		boss1_losses += 1
	elif player_node.name == "Boss2":
		current_loser = 4
		boss2_losses += 1
	elif player_node.name == "Boss3":
		current_loser = 5
		boss3_losses += 1
	else:
		push_error("Unknown player died: " + player_node.name)
		return
	
	rounds += 1
	
	print("PLAYER DIED CALLED: ", player_node.name)
	emit_signal("score_updated", p1_losses, p2_losses, boss1_losses, boss2_losses, boss3_losses)

	if rounds > max_rounds: 
		print("Final Round Reached")
		return

	if current_loser in [3, 4, 5]:
		give_boss_random_card(current_loser)
		go_to_level(current_mode)
	else:
		go_to_level("Card Selection")
	



const CARD_SELECTION_SCENE = "res://Decked/Scenes/Game/Selection/card_selection.tscn"
const TWO_PLAYER_SCENE = "res://Decked/Scenes/Game/Fights/2_player_mode.tscn"
const MENU_SCENE = "res://Decked/Scenes/Game/Selection/menu.tscn"
const SETTINGS_SCENE = "res://Decked/Scenes/Game/Selection/settings.tscn"
const TUTORIAL_SCENE = "res://Decked/Scenes/Game/Tutorial/tutorial.tscn"
const TUTORIAL_PT2_SCENE = "res://Decked/Scenes/Game/Tutorial/tutorial(2).tscn"
const TUTORIAL_PT3_SCENE = "res://Decked/Scenes/Game/Tutorial/tutorial_3.tscn"
const TUTORIAL_PT4_SCENE = "res://Decked/Scenes/Game/Tutorial/tutorial_4.tscn"
const TUTORIAL_PT5_SCENE = "res://Decked/Scenes/Game/Tutorial/tutorial_5.tscn"
const STUDIO_INTRO_SCENE = "res://Decked/Scenes/Game/Transitions/studio_logo.tscn"
const BOSS_ONE_SCENE = "res://Decked/Scenes/Game/Fights/Joe Fight.tscn"
const BOSS_TWO_SCENE = "res://Decked/Scenes/Game/Fights/max_fight.tscn"
const BOSS_THREE_SCENE = "res://Decked/Scenes/Game/Fights/isshin_fight.tscn"
const BOSS_SELECTION_SCENE = "res://Decked/Scenes/Game/Selection/boss_selection.tscn"
const CREDITS_SCENE = "res://Decked/Scenes/Misc/credits.tscn"

var current_mode: String = "" 
var max_rounds := 5

func go_to_level(destination_tag: String):
	var scene_to_load: String = ""
	
	match destination_tag:
		"Menu":
			scene_to_load = MENU_SCENE
		"Settings":
			scene_to_load = SETTINGS_SCENE
		"Card Selection":
			scene_to_load = CARD_SELECTION_SCENE
		"Tutorial":
			scene_to_load = TUTORIAL_SCENE
		"Tutorial Part 2":
			scene_to_load = TUTORIAL_PT2_SCENE
		"Tutorial Part 3":
			scene_to_load = TUTORIAL_PT3_SCENE
		"Tutorial Part 4":
			scene_to_load = TUTORIAL_PT4_SCENE
		"Tutorial Part 5":
			scene_to_load = TUTORIAL_PT5_SCENE
		"2 Player":
			scene_to_load = TWO_PLAYER_SCENE
			current_mode = "2 Player"
		"Joe":
			scene_to_load = BOSS_ONE_SCENE
			current_mode = "Joe"
		"Max":
			scene_to_load = BOSS_TWO_SCENE
			current_mode = "Max"
		"Isshin":
			scene_to_load = BOSS_THREE_SCENE
			current_mode = "Isshin"
		"Boss":
			scene_to_load = BOSS_SELECTION_SCENE
		"Credits":
			scene_to_load = CREDITS_SCENE
	
	if scene_to_load == "":
		push_error("Invalid destination tag: " + destination_tag)
		return
	
	BlackFade.transition()
	await BlackFade.on_transition_finished
	get_tree().change_scene_to_file(scene_to_load)




func restart_round():
	current_loser = 0

	if current_mode == "":
		push_error("No game mode set!")
		go_to_level("2 Player")
		return

	go_to_level(current_mode)



func reset_game():

	current_mode = "" 
	rounds = 1
	current_loser = 0
	
	
	p1_cards.clear()
	p2_cards.clear()
	boss1_cards.clear()
	boss2_cards.clear()
	boss1_cards.clear()
	boss2_cards.clear()
	boss3_cards.clear()
	
	p1_losses = 0
	p2_losses = 0
	boss1_losses = 0
	boss2_losses = 0
	boss3_losses = 0
	emit_signal("score_updated", p1_losses, p2_losses, boss1_losses, boss2_losses, boss3_losses)
	
	for key in p1_stats.keys():
		p1_stats[key] = 0
	for key in p2_stats.keys():
		p2_stats[key] = 0
	for key in boss1_stats.keys():
		boss1_stats[key] = 0
	for key in boss2_stats.keys():
		boss2_stats[key] = 0
	for key in boss3_stats.keys():
		boss3_stats[key] = 0

func _on_player_vs_player_pressed() -> void:
	go_to_level("2 Player")

func _on_boss_fights_pressed() -> void:
	go_to_level("Boss")

func _on_menu_pressed() -> void:
	go_to_level("Menu")
	

func _on_joe_pressed() -> void:
	go_to_level("Joe")


func _on_max_pressed() -> void:
	go_to_level("Max")


func _on_isshin_pressed() -> void:
	go_to_level("Isshin")


func _on_skip_pressed() -> void:
	go_to_level("Menu")


func _on_nextpt4_pressed() -> void:
	go_to_level("Tutorial Part 4")


func _on_settings_pressed() -> void:
	go_to_level("Settings")


func _on_tutorial_pressed() -> void:
	go_to_level("Tutorial")
	


func _on_credits_pressed() -> void:
	go_to_level("Credits")
