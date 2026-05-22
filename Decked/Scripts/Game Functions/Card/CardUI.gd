extends Control
@onready var card_container = $HBoxContainer

var generated_cards = []

var all_cards = []

func _ready():
	_load_cards()
	_generate_options()

func _load_cards():
	all_cards = [
		{
			"name": "Footwork",
			"description": "-30% Dash Cooldown",
			"rarity": "COMMON",
			"buff_type": "dash_cooldown_buff",
			"value": 0.7,
			"icon_path": "res://Decked/Assests/Cards/Footwork.webp"
		},
		{
			"name": "Hearty",
			"description": "+50% Health",
			"rarity": "Common",
			"buff_type": "max_health_buff",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Hearty.png"
		},
		#Sprinting
		{
			"name": "Sprinting",
			"description": "+100% Movement Speed",
			"rarity": "COMMON",
			"buff_type": "move_speed_buff",
			"value": 2.0,
			"icon_path": "res://Decked/Assests/Cards/Sprinting.webp"
		},
		{
			"name": "Counter",
			"description": "If Hit when blocking Deal Damage",
			"rarity": "Common",
			"buff_type": "counter",
			"value": 1.1,
			"icon_path": "res://Decked/Assests/Cards/Counter.webp"
		},
		#Hypeercalcemia
		{
			"name": "Hypercalcemia",
			"description": "+30% defense",
			"rarity": "UNCOMMON",
			"buff_type": "defense",
			"value": 0.7,
			"icon_path": "res://Decked/Assests/Cards/Hypercalcemia-0003.webp"
		},
		{
			"name": "Trickshot",
			"description": "+100% Damage After a Succseful Parry",
			"rarity": "COMMON",
			"buff_type": "trickshot",
			"value": 2.0,
			"icon_path": "res://Decked/Assests/Cards/trickshot.webp"
		},
		{
			"name": "Guardbreaker",
			"description": "More Damage to Blocking Targets",
			"rarity": "RARE",
			"buff_type": "guardbreaker",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Guardbreaker.png"
		},
		{
			"name": "Caffeinated",
			"description": "+50% Movement and Attack Speed",
			"rarity": "Common",
			"buff_type": "caffeinated",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/caffeinated.webp"
		},
		{
			"name": "Weighted Gloves",
			"description": "This feels Like Cheating",
			"rarity": "Uncommon",
			"buff_type": "weighted_gloves",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/weightedGloves.webp"
		},
		{
			"name": "Oiled Up",
			"description": "Now That's Just Weird",
			"rarity": "Common",
			"buff_type": "oiled_up",
			"value": 1.3,
			"icon_path": "res://Decked/Assests/Cards/Oiled_Up.png"
		},
		#Vampire
		{
			"name": "Vampire",
			"description": "+25% Leech",
			"rarity": "UNCOMMON",
			"buff_type": "vampire",
			"value": 1.25,
			"icon_path": "res://Decked/Assests/Cards/Vampire.webp"
		},
		{
			"name": "Bob and Weave",
			"description": "Chance to Dodge Hits",
			"rarity": "Uncommon",
			"buff_type": "bob_and_weave",
			"value": 1.2,
			"icon_path": "res://Decked/Assests/Cards/Bob_N_Weave.webp"
		},
		{
			"name": "Unstoppable",
			"description": "+50% defense when below 33% health",
			"rarity": "Uncommon",
			"buff_type": "unstoppable",
			"value": 0.5,
			"icon_path": "res://Decked/Assests/Cards/unstoppable.webp"
		},
		{
			"name": "Coup de Gras",
			"description": "Kick Em When There Down",
			"rarity": "Uncommon",
			"buff_type": "coup_de_gras",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Coup_De_Gras.png"
		},
		{
			"name": "Uppercut",
			"description": "+50% Damage and Knockback with Charge Punches",
			"rarity": "Uncommon",
			"buff_type": "uppercut",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Uppercut.png"
		},
		#Thorns
		{
			"name": "Thorns",
			"description": "Actions have Repercussions",
			"rarity": "RARE",
			"buff_type": "thorns",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Thorns.webp"
		},
		#Habanero
		{
			"name": "Habanero",
			"description": "Become...       Spicy",
			"rarity": "LEGENDARY",
			"buff_type": "habanero",
			"value": 1.5,
			"icon_path": "res://Decked/Assests/Cards/Habanero.webp"
		},
		{
			"name": "Ninja",
			"description": "Study With the Monks",
			"rarity": "LEGENDARY",
			"buff_type": "ninja",
			"value": 2.0,
			"icon_path": "res://Decked/Assests/Cards/Ninjawhitewashed.webp"
		},
		#Bulldozer
		{
			"name": "Bulldozer",
			"description": "Truck dem Kids",
			"rarity": "LEGENDARY",
			"buff_type": "bulldozer",
			"value": 1.05,
			"icon_path": "res://Decked/Assests/Cards/Bulldozer.webp"
		}
		,
		#Bulldozer
		{
			"name": "Explosive Force",
			"description": "Now this is Just Illegal",
			"rarity": "LEGENDARY",
			"buff_type": "explosion",
			"value": 2.0,
			"icon_path": "res://Decked/Assests/Cards/explosive_force.png"
		}
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
