extends Node

@export var dash_cooldown_buff: float = 1.0
@export var dash_speed_buff: float = 1.0
@export var max_health_buff: float = 1.0
@export var move_speed_buff: float = 1.0
@export var damage_buff: float = 1.0
@export var counter: float = 0.0
@export var defense: float = 1.0
@export var salad: float = 0.0
@export var trickshot: float = 1.0
@export var guardbreaker: float = 1.0
@export var attack_speed_buff: float = 1.0
@export var oiled_up: float = 1.0
@export var vampire: float = 0.0
@export var bob_and_weave: float = 0.0
@export var unstoppable: float = 1.0
@export var coup_de_gras: float = 1.0
@export var charge_damage_buff: float = 1.0
@export var charge_knockback_buff: float = 1.0
@export var knockback_buff: float = 1.0
@export var wizard_fistfight: float = 0.0
@export var thorns: float = 0.0
@export var habenero: float = 0.0
@export var recycling: float = 0.0
@export var bulldozer: float = 0.0
@export var explosion: float = 0.0

var trickshot_punch: bool = false

func _ready() -> void:
	if owner == null:
		return
		
	# 1. Determine which player stats dictionary to pull from
	var player_stats: Dictionary = {}
	match owner.name:
		"Player1":
			player_stats = GameManager.p1_stats
		"Player2":
			player_stats = GameManager.p2_stats
		"Boss1":
			player_stats = GameManager.boss1_stats
		"Boss2":
			player_stats = GameManager.boss2_stats
		"Boss3":
			player_stats = GameManager.boss3_stats
		"Dummy_Idle":
			player_stats = GameManager.dummy_stats
		"Dummy_Charging":
			player_stats = GameManager.dummy_stats
		"Dummy_Shield":
			player_stats = GameManager.dummy_stats
		_:
			return # Exit if the owner isn't a recognized player
			
	# 2. Automatically load all stats that exist in the dictionary
	load_stats_from_manager(player_stats)
	print_all_buffs()

func load_stats_from_manager(stats_dict: Dictionary) -> void:
	# Loop through every key in the player's stat dictionary
	for stat_name in stats_dict.keys():
		# Check if this script actually has a matching export variable
		if stat_name in self:
			# Dynamically set the variable's value. 
			# If the key is "dash_cooldown_buff", it does: self.dash_cooldown_buff = value
			var current_default = self.get(stat_name)
			self.set(stat_name, stats_dict.get(stat_name, current_default))
			
func print_all_buffs() -> void:
	print("--- [%s] LOADED BUFFS ---" % owner.name)
	
	# Loop through all properties defined in this specific script
	for prop in get_script().get_script_property_list():
		# TYPE_FLOAT handles all your buff multipliers; TYPE_BOOL handles trickshot_punch
		if prop.type == TYPE_FLOAT or prop.type == TYPE_BOOL:
			var value = self.get(prop.name)
			print("%s: %s" % [prop.name, value])
			
	print("---------------------------------")
