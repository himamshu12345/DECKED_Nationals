extends State
class_name BossFollow

@export var animator: AnimatedSprite2D
@export var move_speed: float = 30.0
@export var think_interval: float = 0.2

var think_timer: float = 0.0

func Enter():
	if animator:
		animator.play("Idle")

func Physics_Update(delta: float):
	var direction = owner.get_direction_to_opponent()
	var distance = owner.get_distance_to_opponent()
	
	if distance > owner.attack_distance:
		owner.velocity = direction * move_speed
	else:
		owner.velocity = Vector2.ZERO

func Update(delta: float):
	think_timer += delta
	
	if think_timer >= think_interval:
		think_timer = 0.0
		
		var next_action = owner.get_next_action()
		
		if next_action != "Follow":
			transition_state.emit(self, next_action)

func on_charge_hit():
	transition_state.emit(self, "BossConfusedStagger")
	
