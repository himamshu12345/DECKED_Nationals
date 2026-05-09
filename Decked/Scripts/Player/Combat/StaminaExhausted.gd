extends State
class_name StaminaExhausted

const SPEED_MULT: float = 0.4
const BASE_SPEED: float = 50.0

@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix: String = ""

func Enter() -> void:
	animator.play("ConfusedStaggeredLoop")

func Exit() -> void:
	pass

func Update(delta: float) -> void:
	var stamina = _get_stamina()
	if stamina and not stamina.is_exhausted:
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

func _get_stamina() -> Stamina:
	if owner:
		return owner.get_node_or_null("Stamina")
	return null
