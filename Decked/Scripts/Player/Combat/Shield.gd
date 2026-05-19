extends State
class_name Shield

@export var animator : AnimatedSprite2D
@export var input_prefix := ""
@export var speed = 150
@export var audio: AudioStreamPlayer2D

signal shielding(bool)
signal shield_hit(remaining_hits: int)

const BLOCK_ABSORB: float = 0.5
const SHIELD_COOLDOWN: float = 1.5

var cooldown_timer: float = 0.0
var is_attempting_parry: bool = false

signal shield_ready
signal shield_used

#Add to boss
var buffs

func _ready() -> void:
	buffs = owner.get_node_or_null("Buffs")

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

	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_BLOCK)

	is_attempting_parry = false
	shielding.emit(true)
	animator.play("Shield")
	audio.play()
	shield_used.emit()

	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if animator.animation == "Parry":
		is_attempting_parry = false
		if Input.is_action_pressed(input_prefix + "Shield"):
			animator.play("Shield")
		else:
			transition_state.emit(self, "Idle")
	elif animator.animation == "ParryExtends":
		is_attempting_parry = false
		transition_state.emit(self, "Idle")

func Update(_delta: float):
	var stamina = _get_stamina()
	if stamina:
		if stamina.is_exhausted:
			transition_state.emit(self, "StaminaExhausted")
			cooldown_timer = SHIELD_COOLDOWN
			return

	var punch  = input_prefix + "Punch"
	var shield = input_prefix + "Shield"
	var left   = input_prefix + "left"
	var right  = input_prefix + "right"
	var up     = input_prefix + "up"
	var down   = input_prefix + "down"

	if Input.is_action_just_pressed(punch) and not is_attempting_parry:
		attempt_parry()
		return

	if Input.is_action_pressed(shield):
		return

	if is_attempting_parry:
		return

	if Input.get_vector(left, right, up, down):
		transition_state.emit(self, "Move")
	else:
		transition_state.emit(self, "Idle")

# ---------- Parry ----------

func attempt_parry():
	var stamina = _get_stamina()
	if stamina == null or stamina.current_stamina < Stamina.COST_PARRY:
		return
	stamina.consume(Stamina.COST_PARRY)
	is_attempting_parry = true
	animator.play("Parry")

func is_parrying() -> bool:
	return is_attempting_parry

# ---------- Hit callbacks (called from Health.gd) ----------

func on_shield_hit():
	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_BLOCK_HIT)
		if stamina.is_exhausted:
			break_shield()

func on_shield_interrupted():
	break_shield()

func Exit():
	shielding.emit(false)
	cooldown_timer = SHIELD_COOLDOWN
	is_attempting_parry = false
	if animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.disconnect(_on_animation_finished)

func break_shield():
	cooldown_timer = SHIELD_COOLDOWN
	transition_state.emit(self, "ConfusedStaggered")

func Physics_Update(_delta: float):
	var left  = input_prefix + "left"
	var right = input_prefix + "right"
	var up    = input_prefix + "up"
	var down  = input_prefix + "down"
	var direction = Input.get_vector(left, right, up, down)

	var base_speed = 50
	var current_speed = base_speed
	if input_prefix == "":
		current_speed = base_speed * (1.0 + GameManager.p1_stats.get("speed_bonus", 0) / 100.0)
	else:
		current_speed = base_speed * (1.0 + GameManager.p2_stats.get("speed_bonus", 0) / 100.0)

	if owner is CharacterBody2D:
		owner.velocity = direction * current_speed
		owner.move_and_slide()

# ---------- Stamina lookup ----------

func _get_stamina() -> Stamina:
	var node = self
	while node and not node is CharacterBody2D:
		node = node.get_parent()
	if node is CharacterBody2D:
		return node.get_node_or_null("Stamina")
	return null
