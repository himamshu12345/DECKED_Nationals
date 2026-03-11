class_name BossDash
extends State

@export var boss: Boss
@export var sprite: Node2D
@export var cooldown_timer_node: Timer
@export var dash_cooldown: float = 2.0
@export var audio: AudioStreamPlayer2D

const DASH_SPEED: float = 100
const DASH_TIME: float = 0.35
const TRAIL_INTERVAL := 0.05
const MIN_DASH_DISTANCE := 15.0

var dash_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var trail_timer: float = 0.0

signal dash_ready
signal dash_used


func is_ready() -> bool:
	if cooldown_timer_node:
		return cooldown_timer_node.is_stopped()
	return true


func get_cooldown_ratio() -> float:
	if not cooldown_timer_node or cooldown_timer_node.is_stopped():
		return 1.0
	if dash_cooldown <= 0:
		return 1.0
	return 1.0 - (cooldown_timer_node.time_left / dash_cooldown)


func Enter():
	if not is_ready():
		transition_state.emit(self, "Follow")
		return

	if sprite:
		sprite.visible = true

	boss.visible = false

	dash_direction = boss.get_direction_to_opponent()
	audio.play()

	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2.UP.rotated(boss.rotation)

	dash_timer = DASH_TIME
	trail_timer = 0.0

	boss.set_dash_cooldown(dash_cooldown)

	if cooldown_timer_node:
		cooldown_timer_node.wait_time = dash_cooldown
		cooldown_timer_node.one_shot = true
		cooldown_timer_node.start()
		if not cooldown_timer_node.timeout.is_connected(_on_cooldown_finished):
			cooldown_timer_node.timeout.connect(_on_cooldown_finished)

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
			boss.velocity = dash_direction * DASH_SPEED
			dash_timer -= delta
			_spawn_trail(delta)
	else:
		boss.velocity = Vector2.ZERO


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
		var script_res = load("res://Decked/Scripts/Player/Functions/AfterImageFade.gd")
		if script_res:
			ghost.set_script(script_res)

		ghost.global_position = boss.global_position
		ghost.rotation = boss.rotation

		var ghost_sprite = sprite.duplicate()
		ghost.add_child(ghost_sprite)
		ghost_sprite.position = Vector2.ZERO

		var colors = [Color("#ff004d"), Color("#000000"), Color("#5f574f")]
		ghost_sprite.modulate = colors[randi() % colors.size()]

		get_tree().current_scene.add_child(ghost)
