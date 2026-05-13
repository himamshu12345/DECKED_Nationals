extends Node2D

@onready var ready_go_instance: AnimatedSprite2D = $StartGame
@export var entrance_audio: AudioStreamPlayer2D

func _ready():
	MenuMusic.stop_music()
	GameManager.current_mode = "Isshin"
	
	var player = $"Isshin Ring/Player1"
	var boss = $"Isshin Ring/Boss3"
	
	if boss.has_node("Isshin"):
		boss.get_node("Isshin").play("Entrance")
		entrance_audio.play()
		
	
	if ready_go_instance.has_signal("start_game"):
		ready_go_instance.start_game.connect(player.get_node("StateMachine/Idle")._on_start_game)
		ready_go_instance.start_game.connect(boss._on_start_game)
