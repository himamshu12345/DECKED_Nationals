extends State
class_name Idle

@export var player: AnimatedSprite2D
@export var input_prefix := ""
@export var sprite: Node2D

var is_active := false

var _dash_detector := DoubleTapDetector.new()
var _dir_actions: Array[String] = []

func _ready() -> void:
	_dir_actions = [
		input_prefix + "left",
		input_prefix + "right",
		input_prefix + "up",
		input_prefix + "down",
	]
	_dash_detector.setup(_dir_actions)

func Enter() -> void:
	player.play("Idle")
	if sprite == null:
		sprite = player
	sprite.visible = false
	if get_tree().current_scene.is_in_group("tutorial"):
		is_active = true

func _on_start_game() -> void:
	is_active = true

func Update(delta: float) -> void:
	if not is_active:
		return

	var left  = input_prefix + "left"
	var right = input_prefix + "right"
	var up    = input_prefix + "up"
	var down  = input_prefix + "down"
	var punch = input_prefix + "Punch"
	var shield = input_prefix + "Shield"

	# Double-tap any direction to dash
	if _dash_detector.check(_dir_actions) != "":
		transition_state.emit(self, "Dash")
		return

	if Input.get_vector(left, right, up, down):
		transition_state.emit(self, "Move")

	if Input.is_action_just_pressed(punch):
		transition_state.emit(self, "Punch")

	if Input.is_action_just_pressed(shield):
		transition_state.emit(self, "Shield")

func on_idle_hit() -> void:
	transition_state.emit(self, "QuickStagger")

func on_charge_hit() -> void:
	transition_state.emit(self, "ConfusedStaggered")
