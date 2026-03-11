extends State
class_name QuickStagger

@export var player: CharacterBody2D
@export var animator: AnimatedSprite2D
@export var input_prefix := ""
@export var audio: AudioStreamPlayer2D

func Enter():
	animator.play("QuickStagger")
	audio.play()
	if not animator.animation_finished.is_connected(_on_animation_finished):
		animator.animation_finished.connect(_on_animation_finished)
	
func Update(_delta: float):
	var shield = input_prefix + "Shield"
	
	if Input.is_action_just_pressed(shield):
		transition_state.emit(self, "Shield")
		
		
func _on_animation_finished():
	if player.name.begins_with("Dummy"):
		transition_state.emit(self, "DummyIdle")
	transition_state.emit(self, "Idle")
