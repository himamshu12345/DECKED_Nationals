extends State
class_name BossChargePunch

@export var animator: AnimatedSprite2D
@export var hitbox: Area2D
@export var boss: Boss
@export var speed: float = 20.0 # Ported: Boss can now move slowly while charging
@export var chargeAudio: AudioStreamPlayer2D
@export var projectileAudio: AudioStreamPlayer2D
@export var charge_released_audio: AudioStreamPlayer2D

const PROJECTILE_SCENE = preload("res://Decked/Scenes/Player/projectile.tscn")

const BASE_DAMAGE := 10
const FRAMES_PER_CHARGE := 42
const DAMAGE_PER_LEVEL := 3
const MAX_CHARGE_LEVELS := 5
const MAX_CHARGE_HITS := 2

var damage := BASE_DAMAGE
var punchRightNext := false
var chargeFrames := 0.0
var chargeLevel := 0
var chargeHits := 0
var target_charge_level := 0
var charge_released := false
var is_attacking := false
var animation_done := false
var hit_landed := false

var can_shoot := false

func Enter():
	charge_released = false
	chargeFrames = 0.0
	chargeLevel = 0
	chargeHits = 0
	is_attacking = false
	animation_done = false
	hit_landed = false
	
	# Boss 3 logic remains, but now influenced by stats
	can_shoot = (boss and boss.name == "Boss3")
	
	# Ported Logic: Damage + Multiplier (Uppercut stat)
	var bonus = GameManager.boss1_stats.get("damage_bonus", 0)
	var multiplier = GameManager.boss1_stats.get("uppercut", 1.0)
	damage = (BASE_DAMAGE + bonus) * multiplier
	
	# Ported Logic: Pause Stamina Regen
	var stamina = _get_stamina()
	if stamina:
		stamina.pause_regen(true)
	
	target_charge_level = _calculate_target_charge()
	
	animator.play("ChargePunch")
	chargeAudio.play()
	
	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
	
	if hitbox and hitbox.has_signal("hit_landed"):
		if not hitbox.is_connected("hit_landed", _on_hit_landed):
			hitbox.hit_landed.connect(_on_hit_landed)

func _calculate_target_charge() -> int:
	var distance = boss.get_distance_to_opponent()
	if distance < boss.attack_distance:
		return randi_range(1, 2)
	elif distance < boss.attack_distance * 1.5:
		return 3
	else:
		return 4 if can_shoot else 0

func Update(_delta: float):
	if charge_released or is_attacking:
		if is_attacking and animation_done:
			transition_state.emit(self, boss.get_next_action())
		return
	
	# Ported Logic: Stamina drain while holding charge
	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_CHARGE_PER_SEC * _delta)
	
	chargeFrames += _delta * 60.0
	chargeLevel = int(chargeFrames / FRAMES_PER_CHARGE)
	chargeLevel = clamp(chargeLevel, 0, MAX_CHARGE_LEVELS)
	
	if chargeLevel >= target_charge_level:
		charge_released = true
		perform_punch()

func Physics_Update(_delta: float):
	# Ported Logic: Slow movement toward player while charging
	if not charge_released and not is_attacking:
		var direction = boss.get_direction_to_opponent()
		boss.velocity = direction * speed
	else:
		boss.velocity = Vector2.ZERO
		
	if boss is CharacterBody2D:
		boss.move_and_slide()

func on_charge_hit():
	chargeHits += 1
	if chargeHits >= MAX_CHARGE_HITS:
		break_charge()

func break_charge():
	transition_state.emit(self, "BossConfusedStagger")

func perform_punch():
	is_attacking = true
	var final_damage = damage + (chargeLevel * DAMAGE_PER_LEVEL)
	
	if hitbox:
		hitbox.damage = final_damage
	
	var anim := "Right Punch" if punchRightNext else "Left Punch"
	punchRightNext = !punchRightNext
	animator.play(anim)
	
	if hitbox:
		hitbox.enable()
	
	boss.set_charge_punch_cooldown(2.0)

func _on_hit_landed():
	hit_landed = true

func _on_animation_finished():
	if animator.animation in ["Left Punch", "Right Punch"]:
		animation_done = true
		if hitbox:
			hitbox.disable()
		if can_shoot and chargeLevel > 0:
			shoot_projectile()
		
		is_attacking = false
		transition_state.emit(self, "BossIdle")

func shoot_projectile():
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectileAudio.play()
	projectile.global_position = hitbox.global_position if hitbox else boss.global_position
	
	var forward_direction = Vector2(0, -1).rotated(boss.rotation)
	projectile.instigator = boss
	# Projectile damage matches the charge level
	projectile.initialize(forward_direction, damage + (chargeLevel * DAMAGE_PER_LEVEL))

func Exit():
	# Ported Logic: Resume Stamina Regen
	var stamina = _get_stamina()
	if stamina:
		stamina.pause_regen(false)

	if boss.has_method("record_successful_action"):
		if hit_landed:
			boss.record_successful_action("BossChargePunch")
		else:
			boss.record_failed_action("BossChargePunch")
	
	if animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.disconnect(_on_animation_finished)
	
	chargeAudio.stop()
	charge_released_audio.play()

func _get_stamina() -> Stamina:
	if boss:
		return boss.get_node_or_null("Stamina")
	return null
