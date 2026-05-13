extends State
class_name StaminaExhausted

const SPEED_MULT: float = 0.5
const BASE_SPEED: float = 50.0

@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix: String = ""

func Enter() -> void:
	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
	animator.play("ConfusedStaggeredLoop")

func Exit() -> void:
	if animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.disconnect(_on_animation_finished)
	
	
func _on_animation_finished() -> void:
	if animator.animation == "ConfusedStaggeredLoop":
		animator.play("ConfusedStaggeredLoop")

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
