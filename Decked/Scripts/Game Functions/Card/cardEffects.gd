extends Control

@export var angle_x_max: float = 15.0
@export var angle_y_max: float = 15.0
@export var zoom_scale: float = 1.2

@onready var card_texture: TextureRect = $Front

var tween_rot: Tween
var tween_zoom: Tween

func _ready():
	await get_tree().process_frame
	update_pivot()

	if card_texture.material:
		card_texture.material = card_texture.material.duplicate()

	# Connect signals for zoom
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _notification(what):
	if what == NOTIFICATION_RESIZED:
		update_pivot()

func update_pivot():
	pivot_offset = size * 0.5
	if has_node("Front"):
		$Front.pivot_offset = $Front.size * 0.5

func _on_mouse_entered():
	z_index = 10
	if tween_zoom and tween_zoom.is_valid():
		tween_zoom.kill()
	tween_zoom = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_zoom.tween_property(self, "scale", Vector2(zoom_scale, zoom_scale), 0.4)

func _on_mouse_exited():
	z_index = 0

	if tween_rot and tween_rot.is_valid():
		tween_rot.kill()
	tween_rot = create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_rot.tween_method(set_x_rot, card_texture.material.get_shader_parameter("x_rot"), 0.0, 0.5)
	tween_rot.tween_method(set_y_rot, card_texture.material.get_shader_parameter("y_rot"), 0.0, 0.5)

	if tween_zoom and tween_zoom.is_valid():
		tween_zoom.kill()
	tween_zoom = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	tween_zoom.tween_property(self, "scale", Vector2.ONE, 0.5)

func set_x_rot(val: float):
	card_texture.material.set_shader_parameter("x_rot", val)

func set_y_rot(val: float):
	card_texture.material.set_shader_parameter("y_rot", val)

func _gui_input(event: InputEvent) -> void:
	if not event is InputEventMouseMotion:
		return

	var mouse_pos = get_local_mouse_position()
	var lerp_val_x = remap(mouse_pos.x, 0.0, size.x, 0.0, 1.0)
	var lerp_val_y = remap(mouse_pos.y, 0.0, size.y, 0.0, 1.0)

	var rot_x = lerp(-angle_x_max, angle_x_max, lerp_val_y)
	var rot_y = lerp(angle_y_max, -angle_y_max, lerp_val_x)

	set_x_rot(rot_x)
	set_y_rot(rot_y)

func remap(value, from_min, from_max, to_min, to_max):
	return (value - from_min) / (from_max - from_min) * (to_max - to_min) + to_min
