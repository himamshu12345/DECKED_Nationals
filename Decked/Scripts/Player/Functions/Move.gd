extends State
class_name Move


@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix := ""

@export var speed = 50
@export var rotation_speed = 1.5 

func Enter():
	var base_speed = 50
	if input_prefix == "":
		speed = base_speed * (1.0 + GameManager.p1_stats["speed_bonus"] / 100.0)
	else:
		speed = base_speed * (1.0 + GameManager.p2_stats["speed_bonus"] / 100.0)
		
	animator.play("Idle")
	
	
func Update(_delta: float):
	var punch = input_prefix + "Punch"
	var shield = input_prefix + "Shield"
	var dash = input_prefix + "dash"
	
	if(Input.is_action_just_pressed(punch)):
		transition_state.emit(self, "Punch")
	if(Input.is_action_just_pressed(shield)):
		transition_state.emit(self, "Shield")
	if(Input.is_action_just_pressed(dash)):
		transition_state.emit(self, "Dash")

func Physics_Update(delta: float):
	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up" 
	var down = input_prefix + "down"
	
	var direction = Input.get_vector(left, right, up, down)
	if direction != Vector2.ZERO:
		player.velocity = direction * speed
	else:
		transition_state.emit(self, "Idle")

	player.move_and_slide()
	
func on_charge_hit():
	transition_state.emit(self, "ConfusedStaggered")
