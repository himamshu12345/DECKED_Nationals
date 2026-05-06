extends State
class_name StaminaExhausted

const LOCK_DURATION: float = 1.2
const SPEED_MULT: float = 0.4
const BASE_SPEED: float = 50.0

@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix: String = ""

var _timer: float = 0.0

func Enter() -> void:
	_timer = LOCK_DURATION
	animator.play("QuickStagger")

func Exit() -> void:
	pass

func Update(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		transition_state.emit(self, "Idle")

func Physics_Update(_delta: float) -> void:
	var left  = input_prefix + "left"
	var right = input_prefix + "right"
	var up    = input_prefix + "up"
	var down  = input_prefix + "down"
	var direction = Input.get_vector(left, right, up, down)
	if player is CharacterBody2D:
		player.velocity = direction * BASE_SPEED * SPEED_MULT
		player.move_and_slide()
