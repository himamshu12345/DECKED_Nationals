extends State
class_name Move


@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix := ""

@export var speed = 1000
@export var rotation_speed = 1.5 
@export var Accel = 0
@export var Friction = 0
@export var iceTimer = 0

#Add to boss
var buffs


func _ready() -> void:
	buffs = owner.get_node_or_null("Buffs")

func Enter():
	var base_speed = 70
	#Add to boss
	speed = base_speed * buffs.move_speed_buff
		
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
	
	if iceTimer > 0.0:
		iceTimer -= delta
		if iceTimer <= 0.0:
			iceTimer = 0.0
			Accel = 0
			Friction = 0
	
	#add to boss
	var direction = Input.get_vector(left, right, up, down)
	if Accel == 0 and Friction==0:
		if direction != Vector2.ZERO:
			player.velocity = direction * speed
		else:
			transition_state.emit(self, "Idle")
	else:
		var iceSpeed = speed * 3 
		if direction != Vector2.ZERO:
			# Gradually accelerate towards max speed
			player.velocity = player.velocity.lerp(direction * iceSpeed, Accel)
		else:
			# Gradually slide to a stop
			player.velocity = player.velocity.lerp(direction * iceSpeed, Accel)
		if player.velocity.length() < 1.0:
			player.velocity = Vector2.ZERO
			transition_state.emit(self, "Idle")
	player.move_and_slide()
	
func on_charge_hit():
	transition_state.emit(self, "ConfusedStaggered")
