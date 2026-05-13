extends Node2D

@onready var ready_go_instance: AnimatedSprite2D = $StartGame

func _ready():
	MenuMusic.stop_music()
	GameManager.current_mode = "Max"
	
	
	var player = $"Control/Max Ring/Player1"
	var boss = $"Control/Max Ring/Boss2"
	
	if ready_go_instance.has_signal("start_game"):
		ready_go_instance.start_game.connect(player.get_node("StateMachine/Idle")._on_start_game)
		ready_go_instance.start_game.connect(boss._on_start_game)
