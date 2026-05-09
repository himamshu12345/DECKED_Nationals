class_name HealthBar
extends Node2D

@export var player: CharacterBody2D

@onready var health_bar: TextureProgressBar = $Health
@onready var stamina_bar: TextureProgressBar = $Stamina
@onready var indicator: TextureRect = $Indicator

# Charge-level colours (Index 0 is Blue for the initial/neutral state)
const CHARGE_COLORS: Array[Color] = [
	Color(0.18, 0.55, 1.0, 1.0),   # 0 – Blue (Initial/Neutral)
	Color(1.0,  0.894, 0.302, 1.0), # 1 – Yellow
	Color(1.0,  0.549, 0.0,   1.0), # 2 – Orange
	Color(1.0,  0.231, 0.0,   1.0), # 3 – Red-orange
	Color(0.8,  0.0,   0.0,   1.0), # 4 – Deep red
	Color(0.608, 0.0,   1.0,   1.0), # 5 – Purple
]

var _health_node: Health = null
var _stamina_node: Stamina = null
var _flash_timer: float = 0.0
const FLASH_DURATION: float = 0.4

func _ready() -> void:
	# Set Health Bar to Yellow (fff00d)
	health_bar.modulate = Color("fff00d")
	
	if not player:
		return
		
	_health_node  = player.get_node_or_null("Health")
	_stamina_node = player.get_node_or_null("Stamina")

	if _health_node:
		health_bar.max_value = _health_node.max_health
		health_bar.value     = _health_node.current_health
		_health_node.health_changed.connect(_on_health_changed)

	if _stamina_node:
		stamina_bar.max_value = _stamina_node.max_stamina
		stamina_bar.value     = _stamina_node.current_stamina
		_stamina_node.stamina_changed.connect(_on_stamina_changed)
		_stamina_node.stamina_exhausted.connect(_on_stamina_exhausted)
		_stamina_node.stamina_exhausted.connect(_trigger_exhaustion_on_statemachine)

func _process(delta: float) -> void:
	# Stamina bar flash on exhaustion
	if _flash_timer > 0.0:
		_flash_timer -= delta
		var t = _flash_timer / FLASH_DURATION
		# Flashes briefly towards red/white then returns to blue
		stamina_bar.modulate = Color(1.0, t * 0.2, t * 0.2, 1.0)
	else:
		# Keeps the stamina bar blue when not flashing
		stamina_bar.modulate = CHARGE_COLORS[0]

	# Update centre indicator colour from current charge level
	_update_indicator()

func _update_indicator() -> void:
	if not player:
		return
		
	var sm = player.get_node_or_null("StateMachine")
	if not sm:
		return
		
	var state = sm.current_state
	if state == null:
		indicator.modulate = CHARGE_COLORS[0]
		return
		
	# Check if we are currently in a ChargePunch state to update color
	if state.get_class() == "Node" and state.get_script() != null:
		var script_name = state.get_script().get_global_name()
		if script_name == "ChargePunch":
			var level = clamp(state.chargeLevel, 0, CHARGE_COLORS.size() - 1)
			indicator.modulate = CHARGE_COLORS[level]
			return
			
	# Default back to blue
	indicator.modulate = CHARGE_COLORS[0]

func _on_health_changed(new_health: int) -> void:
	health_bar.value = new_health

func _on_stamina_changed(current: float, _maximum: float) -> void:
	stamina_bar.value = current

func _on_stamina_exhausted() -> void:
	_flash_timer = FLASH_DURATION

func _trigger_exhaustion_on_statemachine() -> void:
	if not player:
		return
	var sm = player.get_node_or_null("StateMachine")
	if sm:
		sm.force_change_state("StaminaExhausted")
