extends AnimatedSprite2D

@export var audio: AudioStreamPlayer2D

signal start_game()

func _ready():
	audio.play()
	animation_finished.connect(_on_animation_finished)
		
func _on_animation_finished():
	if animation == "Start":
		start_game.emit()
		print("Signal Emitted: Start Game")
	queue_free()
