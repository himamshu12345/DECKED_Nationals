extends State
class_name BossPunch

@export var animator: AnimatedSprite2D
@export var hitbox: Area2D
@export var damage: int = 5
@export var attack_cooldown: float = 0.2
@export var audio: AudioStreamPlayer2D

var punchRightNext: bool = false
var is_attacking: bool = false
var animation_done: bool = false
var hit_landed: bool = false

var buffs

func _ready() -> void:
	buffs = owner.get_node_or_null("Buffs")

func Enter():
	is_attacking = false
	animation_done = false
	hit_landed = false
	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
	
	if hitbox and hitbox.has_signal("hit_landed"):
		if not hitbox.is_connected("hit_landed", _on_hit_landed):
			hitbox.hit_landed.connect(_on_hit_landed)
	
	perform_punch()

func perform_punch():

	is_attacking = true
	
	if hitbox:
		hitbox.damage = damage
		hitbox.damage += (buffs.bulldozer - 1)*owner.get_node_or_null("Health").max_health
		hitbox.damage *= buffs.damage_buff * buffs.explosion
	
	var anim := "Right Punch" if punchRightNext else "Left Punch"
	punchRightNext = !punchRightNext
	animator.speed_scale = buffs.attack_speed_buff
	animator.play(anim)
	
	if hitbox:
		hitbox.enable()
	
	owner.set_punch_cooldown(attack_cooldown)

func _on_hit_landed():
	hit_landed = true

func _on_animation_finished():
	if animator.animation == "Left Punch" or animator.animation == "Right Punch":
		animation_done = true
		if hitbox:
			hitbox.disable()
		
		is_attacking = false

func Update(delta: float):
	if animation_done:
		var next_action = owner.get_next_action()
		transition_state.emit(self, next_action)

func Exit():
	if owner.has_method("record_successful_action"):
		if hit_landed:
			owner.record_successful_action("BossPunch")
			if owner.has_method("on_successful_hit"):
				owner.on_successful_hit()
		else:
			owner.record_failed_action("BossPunch")
	
	if animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.disconnect(_on_animation_finished)
	
	if hitbox and hitbox.has_signal("hit_landed"):
		if hitbox.is_connected("hit_landed", _on_hit_landed):
			hitbox.hit_landed.disconnect(_on_hit_landed)

func on_charge_hit():
	hit_landed = false
	animation_done = true
	transition_state.emit(self, "BossConfusedStagger")
