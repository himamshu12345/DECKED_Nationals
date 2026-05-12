class_name Health
extends Node

@export var statemachine: StateMachine
@export var hit_animation_player: AnimationPlayer
@export var max_health: int = base_health
@export var parryAudio: AudioStreamPlayer2D
@export var damageTaken: float = 1
@export var lifeSteal: float = 0
@export var thorns: float = 0
@export var gaurdbreaker: float = 0
@export var knockback_bonus: float =0
@export var uppercut: float = 1
@export var coupdegras: float = 1
var current_health: int
var base_health: int = 100

signal health_changed(current: int)

func _ready() -> void:
	if owner == null:
		return

	match owner.name:
		"Player1":
			max_health = base_health * GameManager.p1_stats.get("health_bonus", 0)
			print(max_health)
			damageTaken = GameManager.p1_stats.get("defense_bonus", 0)
			lifeSteal = GameManager.p1_stats.get("leech", 0)
			thorns = GameManager.p1_stats.get("thorns", 0)
			gaurdbreaker = GameManager.p1_stats.get("gaurdbreaker", 0)
			uppercut = GameManager.p1_stats.get("uppercut",0)
			coupdegras = GameManager.p1_stats.get("uppercut",0)
		"Player2":
			max_health = base_health * GameManager.p2_stats.get("health_bonus", 0)
			print(max_health)
			damageTaken = GameManager.p2_stats.get("defense_bonus", 0)
			lifeSteal = GameManager.p2_stats.get("leech", 0)
			thorns = GameManager.p2_stats.get("thorns", 0)
			gaurdbreaker = GameManager.p2_stats.get("gaurdbreaker", 0)
			uppercut = GameManager.p2_stats.get("uppercut",0)
			coupdegras = GameManager.p2_stats.get("uppercut",0)

	current_health = max_health
	health_changed.emit(current_health)

func take_damage(amount: int, enemy_state: String, attacker: Node = null) -> void:
	if statemachine == null or statemachine.current_state == null:
		return

	var state_name := statemachine.current_state.name

	if statemachine.current_state.name in ["Shield", "BossShield", "DummyShield"]:
		var is_parry = false
		if statemachine.current_state.has_method("is_parrying"):
			is_parry = statemachine.current_state.is_parrying()
			
		if is_parry and attacker and attacker.has_node("StateMachine"):
			var attacker_sm = attacker.get_node("StateMachine")
			if enemy_state in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
				var stagger_name = "BossConfusedStagger" if attacker.is_in_group("enemies") else "ConfusedStaggered"
				attacker_sm.force_change_state(stagger_name)
			else:
				var stagger_name = "BossQuickStagger" if attacker.is_in_group("enemies") else "QuickStagger"
				attacker_sm.force_change_state(stagger_name)
			
			parryAudio.play()
			return
			
		if enemy_state == "ChargePunch" or enemy_state == "BossChargePunch":
			statemachine.current_state.on_shield_interrupted()
		else:
			statemachine.current_state.on_shield_hit()
		return
	
	if statemachine.current_state.name in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
		if enemy_state in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
			statemachine.current_state.on_charge_interrupted()
		else:
			statemachine.current_state.on_charge_hit()

	if state_name in ["Move", "Idle", "Punch", "DummyIdle", "BossIdle", "BossFollow", "BossPunch",]:
		if enemy_state in ["ChargePunch", "BossChargePunch"]:
			statemachine.current_state.on_charge_hit()
   
	if state_name in ["Idle", "DummyIdle", "BossIdle"] and enemy_state in ["Punch", "BossPunch"]:
		statemachine.current_state.on_idle_hit()

	current_health = max(current_health - amount*damageTaken, 0) 
	health_changed.emit(current_health)

	if current_health == 0:
		if owner.name == "Dummy_Idle":
			GameManager.go_to_level("Tutorial Part 2")
		elif owner.name == "Dummy_IdlePt2":
			GameManager.go_to_level("Tutorial Part 3")
		elif owner.name == "Dummy_Charging":
			GameManager.go_to_level("Tutorial Part 5")
		die()

func die() -> void:
	print(owner.name, " died")
	if owner.is_in_group("players"):
		statemachine.force_change_state("Death")
	else:
		statemachine.force_change_state("BossDeath")
		
func addHealth(amount: int) -> void:
	current_health = min(current_health+amount*lifeSteal, max_health)
	health_changed.emit(current_health)
