extends Control

@onready var animation_player = $AnimationPlayer

func _ready():
	MenuMusic.play_music_menu()
	animation_player.play("logo_animation")
	animation_player.animation_finished.connect(_on_logo_finished)

func _on_logo_finished(anim_name):
	GameManager.go_to_level("Menu")
