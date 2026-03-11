extends State
class_name DummyShield
@export var animator : AnimatedSprite2D
@export var speed = 150
@export var audio: AudioStreamPlayer2D

signal shielding(bool)
signal shield_hit(remaining_hits: int)

const MAX_SHIELD_HITS := 3
const PARRY_FRAMES := 12
const PARRY_TIME := PARRY_FRAMES / 60.0
const SHIELD_COOLDOWN: float = 0.1

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
		transition_state.emit(self, "DummyIdle")
		return
		
	cooldown_timer = SHIELD_COOLDOWN
	_reset_shield_counter()
	shielding.emit(true)
	shieldHits = 0
	parry_timer = 0.0
	animator.play("Shield")
	audio.play()
	shield_used.emit()
	
func Update(_delta: float):
	parry_timer += _delta

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

func break_shield():
	transition_state.emit(self, "QuickStagger")
	
func _reset_shield_counter() -> void:
	shieldHits = 0
	shield_hit.emit(MAX_SHIELD_HITS)

func Physics_Update(_delta: float):
	pass
