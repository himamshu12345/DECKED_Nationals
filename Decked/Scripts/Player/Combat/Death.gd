extends State
class_name Death

@export var player: AnimatedSprite2D
@export var audio: AudioStreamPlayer2D

var _entered := false

func Enter():
	if _entered:
		return
	_entered = true

	player.play("Death")
	audio.play()

	if not player.animation_finished.is_connected(_on_animation_finished):
		player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished():
	if player.animation_finished.is_connected(_on_animation_finished):
		player.animation_finished.disconnect(_on_animation_finished)
	if owner != null:
		GameManager.player_died(owner)
	
