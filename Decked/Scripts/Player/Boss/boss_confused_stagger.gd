extends State
class_name BossConfusedStagger

@export var player: CharacterBody2D
@export var animator : AnimatedSprite2D
@export var audio: AudioStreamPlayer2D

func Enter():
	animator.play("ConfusedStaggered")
	audio.play()
	
	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
func _on_animation_finished():
	transition_state.emit(self, "BossIdle")
