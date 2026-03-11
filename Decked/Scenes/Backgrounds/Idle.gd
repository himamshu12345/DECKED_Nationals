extends State
class_name Idle

@export var player : AnimatedSprite2D
@export var input_prefix := ""  # Leave empty for P1, set to "p2_" for P2
@export var sprite: Node2D
var is_active := false

func Enter():
	#print("State: Idle")
	player.play("Idle")
	if sprite == null:
		sprite = player
	sprite.visible = false
	if get_tree().current_scene.is_in_group("tutorial"):
		is_active = true
	
func _on_start_game():
	is_active = true
	
func Update(_delta: float):
	if not is_active:
		return
	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up"
	var down = input_prefix + "down"
	var punch = input_prefix + "Punch"
	var shield = input_prefix + "Shield"
	
	if(Input.get_vector(left, right, up, down)):
		transition_state.emit(self, "Move")
	
	if(Input.is_action_just_pressed(punch)):
		transition_state.emit(self, "Punch")
		
	if(Input.is_action_just_pressed(shield)):
		transition_state.emit(self, "Shield")
	

func on_idle_hit():
	transition_state.emit(self, "QuickStagger")

func on_charge_hit():
	transition_state.emit(self, "ConfusedStaggered")
