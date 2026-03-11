extends Control
@onready var card_container = $HBoxContainer

var generated_cards = []

var all_cards = []

func _ready():
	_load_cards()
	_generate_options()

func _load_cards():
	all_cards = [
		#Hypeercalcemia
		{
			"name": "Hypercalcemia",
			"description": "+50 health",
			"rarity": "UNCOMMON",
			"buff_type": "Health",
			"value": 50.0,
			"icon_path": "res://Decked/Assests/Cards/Hypercalcemia-0003.webp"
		},
		#Thorns
		{
			"name": "Thorns",
			"description": "+1 Damage",
			"rarity": "RARE",
			"buff_type": "Damage",
			"value": 1,
			"icon_path": "res://Decked/Assests/Cards/Thorns.webp"
		},
		#Habanero
		{
			"name": "Habanero",
			"description": "+2 Damage",
			"rarity": "LEGENDARY",
			"buff_type": "Damage",
			"value": 2.0,
			"icon_path": "res://Decked/Assests/Cards/Habanero.webp"
		},
		#Vampire
		{
			"name": "Vampire",
			"description": "+0.2 Damage",
			"rarity": "UNCOMMON",
			"buff_type": "Damage",
			"value": 0.2,
			"icon_path": "res://Decked/Assests/Cards/Vampire.webp"
		},
		#Sprinting
		{
			"name": "Sprinting",
			"description": "+100 Movement Speed",
			"rarity": "COMMON",
			"buff_type": "Speed",
			"value": 100.0,
			"icon_path": "res://Decked/Assests/Cards/Sprinting.webp"
		},
		#Bulldozer
		{
			"name": "Bulldozer",
			"description": "+2 damages",
			"rarity": "LEGENDARY",
			"buff_type": "Damage",
			"value": 2.0,
			"icon_path": "res://Decked/Assests/Cards/Bulldozer.webp"
		},
		{
			"name": "Footwork",
			"description": "-20% Dash Cooldown",
			"rarity": "COMMON",
			"buff_type": "DashCooldown",
			"value": 0.4,
			"icon_path": "res://Decked/Assests/Cards/Footwork.webp"
		},
		{
			"name": "Ninja",
			"description": "-75% Dash Cooldown",
			"rarity": "LEGENDARY",
			"buff_type": "DashCooldown",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Ninjawhitewashed.webp"
		},
		{
			"name": "Caffeinated",
			"description": "+100 movement speed",
			"rarity": "Common",
			"buff_type": "Speed",
			"value": 100,
			"icon_path": "res://Decked/Assests/Cards/caffeinated.webp"
		},
		{
			"name": "Hearty",
			"description": "+50 Health",
			"rarity": "Common",
			"buff_type": "Health",
			"value": 50,
			"icon_path": "res://Decked/Assests/Cards/Heartyveiny.webp"
		},
		{
			"name": "Trickshot",
			"description": "+50 Movement Speed",
			"rarity": "COMMON",
			"buff_type": "Speed",
			"value": 50,
			"icon_path": "res://Decked/Assests/Cards/trickshot.webp"
		},
		{
			"name": "Unstoppable",
			"description": "+50 Health",
			"rarity": "Uncommon",
			"buff_type": "Health",
			"value": 50,
			"icon_path": "res://Decked/Assests/Cards/unstoppable.webp"
		},
		{
			"name": "Counter",
			"description": "+0.2 Damage",
			"rarity": "Common",
			"buff_type": "Damage",
			"value": 0.2,
			"icon_path": "res://Decked/Assests/Cards/Counter.webp"
		},
		{
			"name": "Bob and Weave",
			"description": "-30% Dash Cooldown",
			"rarity": "Uncommon",
			"buff_type": "DashCooldown",
			"value": 0.6,
			"icon_path": "res://Decked/Assests/Cards/Bob_N_Weave.webp"
		},
		{
			"name": "Weighted Gloves",
			"description": "+0.5 Damage",
			"rarity": "Uncommon",
			"buff_type": "Damage",
			"value": 0.5,
			"icon_path": "res://Decked/Assests/Cards/weightedGloves.webp"
		},
	]

func _generate_options():
	for child in card_container.get_children():
		child.queue_free()
	
	generated_cards.clear()
	
	await get_tree().process_frame
	
	var available = all_cards.duplicate()
	available.shuffle()
	var options = available.slice(0, min(3, available.size()))
		
	for i in options.size():
		create_card_button(options[i], i * 0.3)

func create_card_button(card: Dictionary, delay: float = 0.0):
	
	var card_scene = preload("res://Decked/Scenes/Misc/card.tscn")
	var card_node = card_scene.instantiate()
	
	card_node.get_node("Front").texture = load(card["icon_path"])
	
	var popup = Panel.new()
	popup.visible = false
	popup.z_index = 10
	
	var label = Label.new()
	label.text = card["description"]
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(100, 0)
	
	popup.add_child(label)
	popup.custom_minimum_size = Vector2(80, 40)
	
	card_node.add_child(popup)
	await get_tree().process_frame
	popup.position = Vector2(15, -50)
	
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0, 0, 0, 0)
	style.corner_radius_top_left = 6
	popup.add_theme_stylebox_override("panel", style)
	var font = load("res://Decked/Assests/Fonts/PixeloidMono/PixeloidSans-Bold.ttf")
	label.add_theme_font_override("font", font)

	var rarity_color = Color(1, 1, 1)
	match card["rarity"].to_lower():
		"common":
			rarity_color = Color(1, 1, 1)
		"uncommon":
			rarity_color = Color(0, 1, 0)
		"rare":
			rarity_color = Color(1, 0.2, 0.2)
		"legendary":
			rarity_color = Color(1, 0.8, 0)

	label.add_theme_color_override("font_color", rarity_color)
	label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("shadow_offset_x", 2)
	label.add_theme_constant_override("shadow_offset_y", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	card_container.add_child(card_node)
	generated_cards.append(card_node)
	
	var button = card_node.get_node("Button")
	button.mouse_entered.connect(func(): popup.visible = true)
	button.mouse_exited.connect(func(): popup.visible = false)

	var timer = get_tree().create_timer(delay)
	await timer.timeout
	
	var anim = card_node.get_node("AnimationPlayer")
	anim.play("card flip")
	
	anim.animation_finished.connect(func(name):
		card_node.get_node("Front").visible = true
		card_node.get_node("Back").visible = false
		
		button.disabled = false
		button.pressed.connect(_on_card_selected.bind(card))
	)

func _on_card_selected(card: Dictionary):
	print("Selected card: ", card["name"])
	
	var loser = GameManager.current_loser
	if loser != 0:
		GameManager.apply_buff(loser, card["buff_type"], card["value"])
		GameManager.add_card(loser, card)
	
	GameManager.restart_round()
