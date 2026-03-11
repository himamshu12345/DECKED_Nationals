extends State
class_name BossShield

@export var animator: AnimatedSprite2D
@export var audio: AudioStreamPlayer2D
@export var min_shield_time: float = 0.5
@export var max_shield_time: float = 2.5

signal shielding(bool)
signal shield_hit(remaining_hits: int)

const MAX_SHIELD_HITS := 3
const PARRY_FRAMES := 15
const PARRY_TIME := PARRY_FRAMES / 60.0
@export var SHIELD_COOLDOWN: float = 0.7
var cooldown_timer: float = 0.0

var shieldHits = 0
var shield_timer: float = 0.0
var shield_duration: float = 1.0
var blocked_hits: int = 0

signal shield_ready
signal shield_used

func _process(delta):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			cooldown_timer = 0.0
			shield_ready.emit()

func Enter():
	if cooldown_timer > 0.0:
		transition_state.emit(self, "Idle")
		return
		
	_reset_shield_counter()
	shielding.emit(true)
	shieldHits = 0
	blocked_hits = 0
	shield_timer = 0.0
	
	var health_percent = 1.0
	var distance = 100.0
	
	if owner.has_method("get_health_percent"):
		health_percent = owner.get_health_percent()
	if owner.has_method("get_distance_to_opponent"):
		distance = owner.get_distance_to_opponent()
	
	if health_percent < 0.25:
		shield_duration = max_shield_time
	elif health_percent < 0.5:
		shield_duration = max_shield_time * 0.7
	elif distance < 20:
		shield_duration = max_shield_time * 0.6
		
	else:
		shield_duration = min_shield_time
	
	if animator:
		animator.play("Shield")
		audio.play()
	
	owner.set_shield_cooldown(3.0)
	shield_used.emit()

func Update(delta: float):
	shield_timer += delta
	
	if shield_timer >= shield_duration:
		if _is_safe_to_drop():
			var next_action = owner.get_next_action()
			transition_state.emit(self, next_action)
		else:
			if shield_timer >= max_shield_time:
				transition_state.emit(self, owner.get_next_action())

func _is_safe_to_drop() -> bool:
	var distance = 100.0
	var attack_dist = 15.0
	
	if owner.has_method("get_distance_to_opponent"):
		distance = owner.get_distance_to_opponent()
	if owner:
		attack_dist = owner.attack_distance
	
	if distance > attack_dist * 1.8:
		return true
	
	if shield_timer >= min_shield_time:
		if blocked_hits > 0:
			return true 
		elif shield_timer >= min_shield_time * 1.5:
			return true
	
	return false

func is_parrying() -> bool:
	return shield_timer <= PARRY_TIME

func on_shield_hit():
	shieldHits += 1
	blocked_hits += 1
	var remaining = MAX_SHIELD_HITS - shieldHits
	shield_hit.emit(remaining)
	
	if shieldHits >= 2 and owner.has_method("get_next_action"):
		var aggression = owner.aggression if "aggression" in owner else 0.5
		
		if randf() < aggression * 0.5:
			transition_state.emit(self, "BossPunch")
			return
	
	if shieldHits >= MAX_SHIELD_HITS:
		break_shield()

func on_shield_interrupted():
	break_shield()

func Exit():
	shielding.emit(false)
	cooldown_timer = SHIELD_COOLDOWN
	
	if owner.has_method("record_successful_action"):
		if blocked_hits >= 2:
			owner.record_successful_action("BossShield")
		elif blocked_hits >= 1:
			pass
		else:
			owner.record_failed_action("BossShield")

func break_shield():
	cooldown_timer = SHIELD_COOLDOWN
	transition_state.emit(self, "BossQuickStagger")

func _reset_shield_counter() -> void:
	shieldHits = 0
	shield_hit.emit(MAX_SHIELD_HITS)

func Physics_Update(_delta: float):
	owner.velocity = Vector2.ZERO
	if owner and owner.has_method("get_distance_to_opponent"):
		var distance = owner.get_distance_to_opponent()
		var attack_dist = owner.attack_distance if owner else 15.0
	
