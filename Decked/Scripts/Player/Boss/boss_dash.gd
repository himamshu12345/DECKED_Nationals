class_name BossDash
extends State

@export var boss: Boss
@export var sprite: Node2D
@export var cooldown_timer_node: Timer
@export var dash_cooldown: float = 2.0
@export var audio: AudioStreamPlayer2D

# Constants turned into defaults to allow for stat modification
const BASE_DASH_SPEED: float = 100.0
const BASE_DASH_TIME: float = 0.35
const TRAIL_INTERVAL := 0.05
const MIN_DASH_DISTANCE := 15.0

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var trail_timer: float = 0.0

# Ported variables from Player Dash
var current_speed := BASE_DASH_SPEED
var current_cooldown := dash_cooldown
var current_time := BASE_DASH_TIME

signal dash_ready
signal dash_used


func is_ready() -> bool:
	if cooldown_timer_node:
		return cooldown_timer_node.is_stopped()
	return true


func get_cooldown_ratio() -> float:
	if not cooldown_timer_node or cooldown_timer_node.is_stopped():
		return 1.0
	if current_cooldown <= 0:
		return 1.0
	return 1.0 - (cooldown_timer_node.time_left / current_cooldown)


func Enter():
	if not is_ready():
		transition_state.emit(self, "Follow")
		return

	# --- Ported Logic: Apply GameManager Stats ---
	current_speed = BASE_DASH_SPEED + GameManager.boss1_stats.get("dashspeed_bonus", 0.0)
	current_cooldown = dash_cooldown - GameManager.boss1_stats.get("dashcooldown_bonus", 0.0)
	# Ensure cooldown doesn't go below a sensible minimum
	current_cooldown = max(0.1, current_cooldown) 
	
	if sprite:
		sprite.visible = true

	boss.visible = false

	dash_direction = boss.get_direction_to_opponent()
	
	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.UP.rotated(boss.rotation)

	dash_timer = current_time
	trail_timer = 0.0

	# Apply the modified cooldown to the boss's internal tracking
	boss.set_dash_cooldown(current_cooldown)

	if cooldown_timer_node:
		cooldown_timer_node.wait_time = current_cooldown
		cooldown_timer_node.one_shot = true
		cooldown_timer_node.start()
		if not cooldown_timer_node.timeout.is_connected(_on_cooldown_finished):
			cooldown_timer_node.timeout.connect(_on_cooldown_finished)

	# --- Ported Logic: Optional Stamina ---
	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_DASH)

	audio.play()
	dash_used.emit()


func _on_cooldown_finished():
	dash_ready.emit()


func Physics_Update(delta: float):
	if dash_timer > 0.0:
		var distance = boss.get_distance_to_opponent()

		if distance <= MIN_DASH_DISTANCE:
			boss.velocity = Vector2.ZERO
			dash_timer = 0.0
		else:
			# Use current_speed instead of constant
			boss.velocity = dash_direction * current_speed
			dash_timer -= delta
			_spawn_trail(delta)
	else:
		boss.velocity = Vector2.ZERO
	
	# Added move_and_slide to match player physics behavior 
	# (Note: Remove if your boss script handles its own physics update)
	if boss is CharacterBody2D:
		boss.move_and_slide()


func Update(delta: float):
	if dash_timer <= 0.0:
		var distance = boss.get_distance_to_opponent()

		if distance <= MIN_DASH_DISTANCE:
			transition_state.emit(self, "BossIdle")
		else:
			var next_action = boss.get_next_action()
			transition_state.emit(self, next_action)


func Exit():
	boss.velocity = Vector2.ZERO
	sprite.visible = false
	boss.visible = true


func _spawn_trail(delta: float):
	if not sprite:
		return

	trail_timer -= delta
	if trail_timer <= 0.0:
		trail_timer = TRAIL_INTERVAL

		var ghost = Node2D.new()
		# Preloading the script to be more efficient like the player script
		var script_res = preload("res://Decked/Scripts/Player/Functions/AfterImageFade.gd")
		ghost.set_script(script_res)

		ghost.global_position = boss.global_position
		ghost.rotation = boss.rotation

		var ghost_sprite = sprite.duplicate()
		ghost.add_child(ghost_sprite)
		ghost_sprite.position = Vector2.ZERO

		# Boss-specific "Dark" palette vs Player "Cyberpunk" palette
		var colors = [Color("#ff004d"), Color("#000000"), Color("#5f574f")]
		ghost_sprite.modulate = colors[randi() % colors.size()]

		get_tree().current_scene.add_child(ghost)

# Helper to check for stamina if you decide to give the boss a stamina bar
func _get_stamina() -> Stamina:
	if boss:
		return boss.get_node_or_null("Stamina")
	return null
