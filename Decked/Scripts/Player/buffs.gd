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
		_:
			return # Exit if the owner isn't a recognized player
			
	# 2. Automatically load all stats that exist in the dictionary
	load_stats_from_manager(player_stats)

func load_stats_from_manager(stats_dict: Dictionary) -> void:
	# Loop through every key in the player's stat dictionary
	for stat_name in stats_dict.keys():
		# Check if this script actually has a matching export variable
		if stat_name in self:
			# Dynamically set the variable's value. 
			# If the key is "dash_cooldown_buff", it does: self.dash_cooldown_buff = value
			var current_default = self.get(stat_name)
			self.set(stat_name, stats_dict.get(stat_name, current_default))
