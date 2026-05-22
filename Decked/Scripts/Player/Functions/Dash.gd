class_name Dash
extends State

@export var player: CharacterBody2D
@export var input_prefix := ""
@export var sprite: Node2D
@export var audio: AudioStreamPlayer2D

const DASH_SPEED: float = 200
const DASH_TIME: float = 1
const DASH_COOLDOWN: float = 4
const TRAIL_INTERVAL := 0.06

var dash_timer: float = 0.0
var cooldown_timer: float = 0.0
var dash_direction: Vector2 = Vector2.ZERO
var trail_timer: float = 0.0
var speed := DASH_SPEED
var cooldown := DASH_COOLDOWN
var time := DASH_TIME

#Add to boss
var buffs

signal dash_ready
signal dash_used

var _cancel_detector := DoubleTapDetector.new()
var _dir_actions: Array[String] = []

func _ready() -> void:
	_dir_actions = [
		input_prefix + "left",
		input_prefix + "right",
		input_prefix + "up",
		input_prefix + "down",
	]
	_cancel_detector.setup(_dir_actions)
	buffs = owner.get_node_or_null("Buffs")

func _process(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta
		if cooldown_timer <= 0.0:
			cooldown_timer = 0.0
			dash_ready.emit()

func Enter() -> void:
	sprite.visible = true
	player.visible = false

	if cooldown_timer > 0.0:
		transition_state.emit(self, "Idle")
		return

	speed = DASH_SPEED
	cooldown = DASH_COOLDOWN
	#Add to boss
	speed *= buffs.dash_speed_buff
	cooldown *= buffs.dash_cooldown_buff

	var x_input: float = Input.get_axis(input_prefix + "left", input_prefix + "right")
	var y_input: float = Input.get_axis(input_prefix + "up", input_prefix + "down")
	dash_direction = Vector2(x_input, y_input).normalized()

	if dash_direction == Vector2.ZERO:
		dash_direction = player.transform.y.normalized()

	dash_timer = time
	cooldown_timer = cooldown
	trail_timer = 0.0

	dash_used.emit()

	var stamina = _get_stamina()
	if stamina:
		stamina.consume(Stamina.COST_DASH)

	audio.play()

func Physics_Update(delta: float) -> void:
	if cooldown_timer > 0.0:
		cooldown_timer -= delta

	if dash_timer >= 0.0:
		# Double-tap any direction mid-dash to cancel
		if _cancel_detector.check(_dir_actions) != "":
			player.velocity = Vector2.ZERO
			transition_state.emit(self, "Idle")
			return

		# Steer freely with live input; hold last direction if no input
		var x_input: float = Input.get_axis(input_prefix + "left", input_prefix + "right")
		var y_input: float = Input.get_axis(input_prefix + "up", input_prefix + "down")
		var live_dir := Vector2(x_input, y_input).normalized()
		if live_dir != Vector2.ZERO:
			dash_direction = live_dir

		player.velocity = dash_direction * speed
		dash_timer -= delta
		_spawn_trail(delta)
	else:
		player.velocity = Vector2.ZERO
		transition_state.emit(self, "Idle")

	player.move_and_slide()

func Exit() -> void:
	sprite.visible = false
	player.visible = true

func _cyberpunk_color() -> Color:
	var colors = [
		Color("#078d70"),
		Color("#26cda9"),
		Color("#99e8c2"),
		Color("#ffffff"),
		Color("#7bade3"),
		Color("#5049cb"),
		Color("#3e1a78"),
	]
	return colors[randi() % colors.size()]

func _spawn_trail(delta: float) -> void:
	trail_timer -= delta
	if trail_timer <= 0.0:
		trail_timer = TRAIL_INTERVAL
		var ghost = Node2D.new()
		ghost.set_script(preload("res://Decked/Scripts/Player/Functions/AfterImageFade.gd"))
		ghost.global_position = player.global_position
		ghost.global_rotation = player.global_rotation
		ghost.scale = sprite.global_transform.get_scale()
		var ghost_sprite = sprite.duplicate()
		ghost.add_child(ghost_sprite)
		ghost_sprite.position = Vector2.ZERO
		ghost_sprite.rotation = 0.0
		ghost_sprite.scale = Vector2.ONE
		ghost_sprite.modulate = _cyberpunk_color()
		get_tree().current_scene.add_child(ghost)

func _get_stamina() -> Stamina:
	if owner:
		return owner.get_node_or_null("Stamina")
	return null
