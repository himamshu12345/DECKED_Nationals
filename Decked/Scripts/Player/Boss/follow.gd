extends State
class_name BossFollow

@export var animator: AnimatedSprite2D
@export var move_speed: float = 60.0
@export var think_interval: float = 0.2
@export var Accel = 0
@export var Friction = 0
@export var iceTimer = 0

var think_timer: float = 0.0

var buffs

func _ready() -> void:
	buffs = owner.get_node_or_null("Buffs")

func Enter():
	var base_speed = 80
	#Add to boss
	move_speed = base_speed * buffs.move_speed_buff
	if animator:
		animator.play("Idle")

func Physics_Update(delta: float):
	var direction = owner.get_direction_to_opponent()
	var distance = owner.get_distance_to_opponent()
	
	if iceTimer > 0.0:
		iceTimer -= delta
		if iceTimer <= 0.0:
			iceTimer = 0.0
			Accel = 0
			Friction = 0
			
	if Accel == 0 and Friction==0:
		if direction != Vector2.ZERO:
			owner.velocity = direction * move_speed
	else:
		if direction != Vector2.ZERO:
			# Gradually accelerate towards max speed
			owner.velocity = owner.velocity.lerp(direction * move_speed, Accel)
		else:
			# Gradually slide to a stop
			owner.velocity = owner.velocity.lerp(direction * move_speed, Accel)
		if owner.velocity.length() < 1.0:
			owner.velocity = Vector2.ZERO
			transition_state.emit(self, "Bossidle")
	
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
	
