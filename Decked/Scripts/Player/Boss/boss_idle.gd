extends State
class_name BossIdle

@export var animator: AnimatedSprite2D
@export var detection_radius: float = 300.0
@export var think_interval: float = 0.3
@export var sprite: Node2D

var think_timer: float = 0.0

func Enter():
	sprite.visible = false
	owner.velocity = Vector2.ZERO
	if animator:
		animator.play("Idle")

func Update(delta: float):
	think_timer += delta
	
	if not owner.is_active:
		return
	
	if think_timer >= think_interval:
		think_timer = 0.0
		
		var distance = owner.get_distance_to_opponent()
		
		if distance < detection_radius:
			transition_state.emit(self, "Follow")

func on_charge_hit():
	transition_state.emit(self, "BossConfusedStagger")
