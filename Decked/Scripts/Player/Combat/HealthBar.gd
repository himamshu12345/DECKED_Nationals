class_name HealthBar
extends Control

@onready var left_bar = $LeftBar
@onready var right_bar = $RightBar
@export var player: CharacterBody2D
@onready var health: Health = player.find_children("*", "Health")[0]
@onready var dash_indicator = $DashIndicator
@export var card_slots: Array[TextureRect]
@onready var shield_indicator = $ShieldIndicator

var default_left_tint: Color
var default_right_tint: Color
var shield_state
var dash_state

func _ready() -> void:
	default_left_tint = Color("#fff00d")
	default_right_tint = Color("#fff00d")

	left_bar.tint_progress = default_left_tint
	right_bar.tint_progress = default_right_tint

	left_bar.max_value = health.max_health
	right_bar.max_value = health.max_health
	left_bar.value = health.current_health
	right_bar.value = health.current_health

	health.health_changed.connect(_update_bar)

	shield_state = _find_shield_state(player)
	if shield_state:
		shield_state.shielding.connect(_on_shielding_changed)
		shield_state.shield_hit.connect(_on_shield_hit)
		shield_state.shield_ready.connect(_on_shield_ready)
		shield_state.shield_used.connect(_on_shield_used)
	else:
		print("No shield state found for ", player.name)

	dash_state = _find_dash_state(player)
	if dash_state:
		dash_state.dash_ready.connect(_on_dash_ready)
		dash_state.dash_used.connect(_on_dash_used)
	else:
		print("No dash state found for ", player.name)

	if dash_state and dash_state.has_method("is_ready"):
		if dash_state.is_ready():
			_on_dash_ready()
		else:
			_set_indicator_grayed()
			
	
	if shield_state and shield_state.has_method("is_ready"):
		if shield_state.is_ready():
			_on_shield_ready()
		else:
			_set_shield_grayed()
	update_cards()


func update_cards():
	var cards = []
	if player.name == "Player1":
		cards = GameManager.p1_cards
	elif player.name == "Player2":
		cards = GameManager.p2_cards
	elif player.name == "Boss1":
		cards = GameManager.boss1_cards
	elif player.name == "Boss2":
		cards = GameManager.boss2_cards
	elif player.name == "Boss3":
		cards = GameManager.boss3_cards

	for i in range(min(cards.size(), card_slots.size())):
		var card_data = cards[i]
		if card_slots[i]:
			card_slots[i].expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			card_slots[i].stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			card_slots[i].texture = load(card_data["icon_path"])
			card_slots[i].visible = true


func _find_shield_state(node: Node):
	if node.has_signal("shielding") and node.has_signal("shield_hit"):
		return node
	for child in node.get_children():
		var result = _find_shield_state(child)
		if result:
			return result
	return null


func _find_dash_state(node: Node):
	for child in node.get_children():
		if child.get_script() != null:
			var script_path: String = child.get_script().resource_path
			if "Dash" in child.get_script().get_global_name():
				return child
		var result = _find_dash_state(child)
		if result:
			return result
	return null


func _set_indicator_grayed():
	dash_indicator.stop()
	dash_indicator.frame = 0
	dash_indicator.modulate = Color(0.35, 0.35, 0.35, 1.0)
	
func _set_shield_grayed():
	shield_indicator.stop()
	shield_indicator.frame = 0
	shield_indicator.modulate = Color(0.35, 0.35, 0.35, 1.0)


func _update_bar(new_health: int) -> void:
	left_bar.value = new_health
	right_bar.value = new_health


func _on_shielding_changed(is_shielding: bool) -> void:
	if is_shielding:
		var max_hits = shield_state.MAX_SHIELD_HITS if "MAX_SHIELD_HITS" in shield_state else 6
		var current_hits = shield_state.shieldHits if "shieldHits" in shield_state else 0

		left_bar.max_value = max_hits
		right_bar.max_value = max_hits
		left_bar.value = max_hits - current_hits
		right_bar.value = max_hits - current_hits

		left_bar.tint_progress = Color.LIGHT_SKY_BLUE
		right_bar.tint_progress = Color.LIGHT_SKY_BLUE
	else:
		left_bar.max_value = health.max_health
		right_bar.max_value = health.max_health
		left_bar.value = health.current_health
		right_bar.value = health.current_health

		left_bar.tint_progress = default_left_tint
		right_bar.tint_progress = default_right_tint


func _on_shield_hit(remaining_hits: int) -> void:
	left_bar.value = remaining_hits
	right_bar.value = remaining_hits


func _on_dash_ready():
	if not dash_indicator:
		return
	dash_indicator.modulate = Color(1.0, 1.0, 1.0, 1.0)
	dash_indicator.play("default")
	if not dash_indicator.animation_finished.is_connected(_on_dash_anim_finished):
		dash_indicator.animation_finished.connect(_on_dash_anim_finished)
		

func _on_shield_ready():
	if not shield_indicator:
		return
	shield_indicator.modulate = Color(1.0, 1.0, 1.0, 1.0)
	shield_indicator.play("default")
	if not shield_indicator.animation_finished.is_connected(_on_shield_anim_finished):
		shield_indicator.animation_finished.connect(_on_shield_anim_finished)

func _on_dash_anim_finished():
	dash_indicator.stop()
	dash_indicator.frame = 6

func _on_shield_anim_finished():
	shield_indicator.stop()
	shield_indicator.frame = 7

func _on_dash_used():
	_set_indicator_grayed()
	
func _on_shield_used():
	_set_shield_grayed()
