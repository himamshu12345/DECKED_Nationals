extends State
class_name BossChargePunch

@export var animator: AnimatedSprite2D
@export var hitbox: Area2D
@export var boss: Boss
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
	
	if boss and boss.name == "Boss3":
		can_shoot = true
	else:
		can_shoot = false
	
	damage = BASE_DAMAGE + GameManager.boss1_stats.get("damage_bonus", 0)
	
	target_charge_level = _calculate_target_charge()
	
	animator.play("ChargePunch")
	chargeAudio.play()
	
	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
	
	if hitbox and hitbox.has_signal("hit_landed"):
		if not hitbox.is_connected("hit_landed", _on_hit_landed):
			hitbox.hit_landed.connect(_on_hit_landed)

func _calculate_target_charge() -> int:
	"""AI determines optimal charge level based on situation"""
	var distance = boss.get_distance_to_opponent()
	var health_percent = boss.get_health_percent()
	var aggression = boss.aggression if boss else 0.7
	
	if distance < boss.attack_distance:
		return randi_range(1, 2)

	elif distance < boss.attack_distance * 1.5:
		return 2

	else:
		if can_shoot:
			return randi_range(1, 2)
		return 0



func Update(_delta: float):
	if charge_released or is_attacking:
		if is_attacking and animation_done:
			var next_action = boss.get_next_action()
			transition_state.emit(self, next_action)
		return
	
	chargeFrames += _delta * 60.0
	chargeLevel = int(chargeFrames / FRAMES_PER_CHARGE)
	chargeLevel = clamp(chargeLevel, 0, MAX_CHARGE_LEVELS)
	
	if chargeLevel >= target_charge_level:
		charge_released = true
		perform_punch()

func on_charge_hit():
	chargeHits += 1
	if chargeHits >= MAX_CHARGE_HITS:
		break_charge()

func on_charge_interrupted():
	break_charge()

func break_charge():
	animation_done = true
	hit_landed = false
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
	if animator.animation == "Left Punch" or animator.animation == "Right Punch":
		animation_done = true
		
		if hitbox:
			hitbox.disable()

		if can_shoot:
			if chargeLevel > 0:
				shoot_projectile()
		
		is_attacking = false
		transition_state.emit(self, "Bossidle")
func shoot_projectile():
	if not PROJECTILE_SCENE:
		push_error("BossChargePunch: Projectile scene not found!")
		return
	
	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)
	projectileAudio.play()
	
	projectile.global_position = hitbox.global_position if hitbox else boss.global_position
	
	var forward_direction = Vector2(0, -1).rotated(boss.rotation)
	
	projectile.instigator = boss
	projectile.initialize(forward_direction, damage + (chargeLevel * DAMAGE_PER_LEVEL))

func Exit():
	if boss.has_method("record_successful_action"):
		if hit_landed:
			boss.record_successful_action("BossChargePunch")
			if boss.has_method("on_successful_hit"):
				boss.on_successful_hit()
		else:
			if is_attacking:
				boss.record_failed_action("BossChargePunch")
	
	if animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.disconnect(_on_animation_finished)
	
	if hitbox and hitbox.has_signal("hit_landed"):
		if hitbox.is_connected("hit_landed", _on_hit_landed):
			hitbox.hit_landed.disconnect(_on_hit_landed)
	chargeAudio.stop()
	charge_released_audio.play()
