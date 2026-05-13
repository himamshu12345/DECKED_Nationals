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

var shieldHits = 0
var shield_timer: float = 0.0
var shield_duration: float = 1.0
var blocked_hits: int = 0
var cooldown_timer: float = 0.0

# --- Ported Stat Variables ---
var current_cooldown := SHIELD_COOLDOWN
var current_speed_mult := 1.0
# -----------------------------

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
		transition_state.emit(self, "BossIdle") # Consistent with boss naming
		return
	
	# --- Ported Logic: GameManager Stats & Stamina ---
	current_cooldown = SHIELD_COOLDOWN - GameManager.boss1_stats.get("shieldcooldown_bonus", 0.0)
	current_speed_mult = 1.0 + (GameManager.boss1_stats.get("speed_bonus", 0.0) / 100.0)
	
	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_BLOCK)
	# ------------------------------------------------
		
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
	
	# Dynamic duration based on boss health/distance
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
	
	# Apply the stat-modified cooldown to the boss controller
	owner.set_shield_cooldown(max(0.2, current_cooldown * 4.0)) # Scaling the external cooldown
	shield_used.emit()

func Update(delta: float):
	shield_timer += delta
	
	# Ported Logic: Allow boss to "counter" with a punch if hit (Aggression check)
	if shieldHits >= 2 and owner.has_method("get_next_action"):
		var aggression = owner.aggression if "aggression" in owner else 0.5
		if randf() < aggression * 0.5:
			transition_state.emit(self, "BossPunch")
			return
	
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
	
	if shieldHits >= MAX_SHIELD_HITS:
		break_shield()

func on_shield_interrupted():
	break_shield()

func Exit():
	shielding.emit(false)
	cooldown_timer = current_cooldown
	
	if owner.has_method("record_successful_action"):
		if blocked_hits >= 2:
			owner.record_successful_action("BossShield")
		else:
			owner.record_failed_action("BossShield")

func break_shield():
	cooldown_timer = current_cooldown * 2.0 # Extra penalty for shield break
	transition_state.emit(self, "BossQuickStagger")

func _reset_shield_counter() -> void:
	shieldHits = 0
	shield_hit.emit(MAX_SHIELD_HITS)

func Physics_Update(_delta: float):
	# Ported Logic: Movement while shielding
	# Unlike the player, the boss moves based on its target, not buttons
	var direction = Vector2.ZERO
	if owner.has_method("get_direction_to_opponent"):
		direction = owner.get_direction_to_opponent()
	
	var base_move_speed = 30.0 # Bosses move slower while shielding
	var move_velocity = direction * base_move_speed * current_speed_mult
	
	# Only move if the boss wants to maintain a certain distance
	if owner.has_method("get_distance_to_opponent"):
		var dist = owner.get_distance_to_opponent()
		if dist < 15.0: # Too close, back up
			owner.velocity = -direction * base_move_speed * current_speed_mult
		elif dist > 40.0: # Too far, creep forward
			owner.velocity = direction * (base_move_speed * 0.5) * current_speed_mult
		else:
			owner.velocity = Vector2.ZERO
	
	if owner is CharacterBody2D:
		owner.move_and_slide()

func _get_stamina() -> Stamina:
	if owner:
		return owner.get_node_or_null("Stamina")
	return null
