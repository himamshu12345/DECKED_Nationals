extends State
class_name Shield

@export var animator : AnimatedSprite2D
@export var input_prefix := ""
@export var speed = 150
@export var audio: AudioStreamPlayer2D


signal shielding(bool)
signal shield_hit(remaining_hits: int)

const MAX_SHIELD_HITS := 3
const PARRY_FRAMES := 15
const PARRY_TIME := PARRY_FRAMES / 60.0
const SHIELD_COOLDOWN: float = 1.5

var shieldHits = 0
var parry_timer: float = 0.0
var cooldown_timer: float = 0.0

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
	parry_timer = 0.0
	animator.play("Shield")
	audio.play()
	shield_used.emit()
	
func Update(_delta: float):
	parry_timer += _delta
	
	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up"
	var down = input_prefix + "down"
	var punch = input_prefix + "Punch"
	var shield = input_prefix + "Shield"
	
	if(Input.is_action_just_pressed(punch)):
		transition_state.emit(self, "Punch")
		return

	if Input.is_action_pressed(shield):
		return
		
	if is_parrying():
		return

	if(Input.get_vector(left, right, up, down)):
		transition_state.emit(self, "Move")
	else:
		transition_state.emit(self, "Idle")
	

func is_parrying() -> bool:
	return parry_timer <= PARRY_TIME

func on_shield_hit():
	shieldHits += 1
	var remaining = MAX_SHIELD_HITS - shieldHits
	shield_hit.emit(remaining)
	
	if shieldHits >= MAX_SHIELD_HITS:
		break_shield()
		
func on_shield_interrupted():
	break_shield()

func Exit():
	shielding.emit(false)
	cooldown_timer = SHIELD_COOLDOWN

func break_shield():
	transition_state.emit(self, "ConfusedStaggered")
	cooldown_timer = SHIELD_COOLDOWN
	
func _reset_shield_counter() -> void:
	shieldHits = 0
	shield_hit.emit(MAX_SHIELD_HITS)

func Physics_Update(_delta: float):
	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up" 
	var down = input_prefix + "down"
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
