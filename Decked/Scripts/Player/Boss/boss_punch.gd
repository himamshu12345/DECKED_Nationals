extends State
class_name BossPunch

@export var animator: AnimatedSprite2D
@export var hitbox: Area2D
@export var damage: int = 5
@export var attack_cooldown: float = 0.2
@export var audio: AudioStreamPlayer2D

# --- Ported Variables from Punch.gd ---
@export var punchSpeed: float = 1.0
@export var bulldozer_buff: float = 0.0
@export var explosion: float = 1.0
var current_damage := 0.0
# --------------------------------------

var punchRightNext: bool = false
var is_attacking: bool = false
var animation_done: bool = false
var hit_landed: bool = false

func Enter():
	is_attacking = false
	animation_done = false
	hit_landed = false
	
	# Ported Logic: Fetching stats from GameManager
	current_damage = damage + GameManager.boss1_stats.get("damage_bonus", 0)
	punchSpeed = GameManager.boss1_stats.get("punchSpeed", 1.0)
	bulldozer_buff = GameManager.boss1_stats.get("bulldozer", 0.0)
	explosion = GameManager.boss1_stats.get("explosion", 1.0)
	
	# Ported Logic: Bulldozer buff (adds damage based on max health)
	var health_node = owner.get_node_or_null("Health")
	if health_node:
		current_damage += bulldozer_buff * health_node.max_health

	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
	
	if hitbox and hitbox.has_signal("hit_landed"):
		if not hitbox.is_connected("hit_landed", _on_hit_landed):
			hitbox.hit_landed.connect(_on_hit_landed)
	
	perform_punch()

func perform_punch():
	is_attacking = true
	
	if hitbox:
		# Ported Logic: Explosion multiplier applied to damage
		hitbox.damage = current_damage * explosion
	
	var anim := "Right Punch" if punchRightNext else "Left Punch"
	punchRightNext = !punchRightNext
	
	# Ported Logic: Health-based speed scaling (Unstoppable mechanic)
	var health = owner.get_node_or_null("Health")
	var final_speed = punchSpeed
	
	if health and health.max_health > 0:
		if health.current_health / health.max_health <= 0.33:
			# Only apply if the health node actually has the unstoppable variable
			var unstoppable_val = health.get("unstoppable") if "unstoppable" in health else 0.0
			final_speed *= 1.0 + (unstoppable_val * 2.0)
	
	animator.speed_scale = final_speed
	animator.play(anim)
	
	if audio: 
		audio.play()
	
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
	# Reset speed scale so other states aren't affected by the punch speed
	animator.speed_scale = 1.0
	
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
