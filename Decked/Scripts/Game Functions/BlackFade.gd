extends CanvasLayer

signal on_transition_finished

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "Hide Screen":
		on_transition_finished.emit()
		animation_player.play("Reveal Screen")
	
	elif anim_name == "Reveal Screen":
		print("Transition complete!")

func transition():
	animation_player.play("Hide Screen")
