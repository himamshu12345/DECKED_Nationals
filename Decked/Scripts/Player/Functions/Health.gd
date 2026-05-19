class_name Health
extends Node

@export var statemachine: StateMachine
@export var hit_animation_player: AnimationPlayer
@export var max_health: int = 100
@export var parryAudio: AudioStreamPlayer2D

var current_health: int

#Add to Boss
var buffs

signal health_changed(current: int)

func _ready() -> void:
	#add to boss
	buffs = owner.get_node_or_null("Buffs")
	max_health *= buffs.max_health_buff
	
	current_health = max_health
	health_changed.emit(current_health)

func take_damage(amount: int, enemy_state: String, attacker: Node = null) -> void:
	if statemachine == null or statemachine.current_state == null:
		return

	var state_name := statemachine.current_state.name

	# ── Already stunned — take raw damage only, don't extend the stagger ──
	const STAGGER_STATES := [
		"ConfusedStaggered", "QuickStagger",
		"BossConfusedStagger", "BossQuickStagger"
	]
	if state_name in STAGGER_STATES:
		_apply_damage(amount)
		return

	if state_name in ["Shield", "BossShield", "DummyShield"]:
		var is_parry = false
		if statemachine.current_state.has_method("is_parrying"):
			is_parry = statemachine.current_state.is_parrying()

		# ── Parry success ──────────────────────────────────────────────────
		if is_parry and attacker and attacker.has_node("StateMachine"):
			var attacker_sm = attacker.get_node("StateMachine")
			var defender_stamina = owner.get_node_or_null("Stamina")
			if enemy_state in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
				var stagger = "BossConfusedStagger" if attacker.is_in_group("enemies") else "ConfusedStaggered"
				attacker_sm.force_change_state(stagger)
				if defender_stamina:
					defender_stamina.recover(Stamina.RECOVER_PARRY_CHARGE)
			else:
				var stagger = "BossQuickStagger" if attacker.is_in_group("enemies") else "QuickStagger"
				attacker_sm.force_change_state(stagger)
				if defender_stamina:
					defender_stamina.recover(Stamina.RECOVER_PARRY)
			parryAudio.play()
			return

		# ── Blocked hit (no parry) ─────────────────────────────────────────
		attacker.get_node_or_null("Health").take_damage(int(ceil(amount*(buffs.counter-1))),state_name,owner)
		if enemy_state in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
			var shield_state = statemachine.current_state
			shield_state.on_shield_interrupted()
			_apply_damage(amount)
		else:
			var shield_state = statemachine.current_state
			shield_state.on_shield_hit()
			var absorb = shield_state.BLOCK_ABSORB if shield_state is Shield else 0.5
			_apply_damage(int(amount * absorb))
		return

	if state_name in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
		if enemy_state in ["ChargePunch", "BossChargePunch", "DummyCharging"]:
			if statemachine.current_state.has_method("on_charge_interrupted"):
				statemachine.current_state.on_charge_interrupted()
		else:
			if statemachine.current_state.has_method("on_charge_hit"):
				statemachine.current_state.on_charge_hit()

	if state_name in ["Move", "Idle", "Punch", "DummyIdle", "BossIdle", "BossFollow", "BossPunch"]:
		if enemy_state in ["ChargePunch", "BossChargePunch"]:
			if statemachine.current_state.has_method("on_charge_hit"):
				statemachine.current_state.on_charge_hit()

	if state_name in ["Idle", "DummyIdle", "BossIdle"] and enemy_state in ["Punch", "BossPunch"]:
		if statemachine.current_state.has_method("on_idle_hit"):
			statemachine.current_state.on_idle_hit()

	_apply_damage(amount*buffs.defense)

func _apply_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	health_changed.emit(current_health)
	if current_health == 0:
		if owner.name == "Dummy_Idle":
			GameManager.go_to_level("Tutorial Part 4")
		die()

func die() -> void:
	print(owner.name, " died")
	if owner.is_in_group("players"):
		statemachine.force_change_state("Death")
	else:
		statemachine.force_change_state("BossDeath")
