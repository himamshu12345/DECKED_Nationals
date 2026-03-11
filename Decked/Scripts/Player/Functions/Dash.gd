class_name Dash
extends State

@export var player: CharacterBody2D
@export var input_prefix := ""
@export var sprite: Node2D
@export var audio: AudioStreamPlayer2D

const DASH_SPEED: float = 100
const DASH_TIME: float  = 0.35
const DASH_COOLDOWN: float = 2
const TRAIL_INTERVAL := 0.06

var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var trail_timer: float = 0.0
var speed := DASH_SPEED
var cooldown := DASH_COOLDOWN
var time := DASH_TIME

signal dash_ready
signal dash_used


func _process(delta):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

		if cooldown_timer <= 0.0:
			cooldown_timer = 0.0
			dash_ready.emit()


func Enter():
	sprite.visible = true
	player.visible = false

	if cooldown_timer > 0.0:
		transition_state.emit(self, "Idle")
		return

	speed = DASH_SPEED
	cooldown = DASH_COOLDOWN

	if input_prefix == "":
		speed += GameManager.p1_stats["dashspeed_bonus"]
		cooldown -= GameManager.p1_stats["dashcooldown_bonus"]
	else:
		speed += GameManager.p2_stats["dashspeed_bonus"]
		cooldown -= GameManager.p2_stats["dashcooldown_bonus"]

	var left = input_prefix + "left"
	var right = input_prefix + "right"
	var up = input_prefix + "up"
	var down = input_prefix + "down"

	var x_input: float = Input.get_axis(left, right)
	var y_input: float = Input.get_axis(up, down)

	dash_direction = Vector2(x_input, y_input).normalized()

	if dash_direction == Vector2.ZERO:
		dash_direction = player.transform.y.normalized()

	dash_timer = time
	cooldown_timer = cooldown
	trail_timer = 0.0

	dash_used.emit()

	audio.play()


func Physics_Update(delta: float):
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if dash_timer >= 0.0:
		player.velocity = dash_direction * speed
		dash_timer -= delta
		_spawn_trail(delta)
	else:
		player.velocity = Vector2.ZERO
		transition_state.emit(self, "Idle")

	player.move_and_slide()


func _cyberpunk_color() -> Color:
	var colors = [
		Color("#078d70"),
		Color("#26cda9"),
		Color("#99e8c2"),
		Color("#ffffff"),
		Color("#7bade3"),
		Color("#5049cb"),
		Color("#3e1a78")
	]
	return colors[randi() % colors.size()]


func _spawn_trail(delta):
	trail_timer -= delta

	if trail_timer <= 0.0:
		trail_timer = TRAIL_INTERVAL

		var ghost = Node2D.new()
		ghost.set_script(preload("res://Decked/Scripts/Player/Functions/AfterImageFade.gd"))

		ghost.global_position = player.global_position
		ghost.rotation = player.rotation

		var ghost_sprite = sprite.duplicate()
		ghost.add_child(ghost_sprite)
		ghost_sprite.position = Vector2.ZERO
		ghost_sprite.modulate = _cyberpunk_color()

		get_tree().current_scene.add_child(ghost)


func Exit():
	sprite.visible = false
	player.visible = true
