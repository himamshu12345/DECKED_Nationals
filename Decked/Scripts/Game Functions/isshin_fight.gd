extends Node2D

func _ready():
	MenuMusic.stop_music()
	GameManager.current_mode = "Isshin"
	
	var ready_go_scene = preload("res://Decked/Scenes/Backgrounds/ready_go.tscn")
	var ready_go_instance = ready_go_scene.instantiate()
	$Control.add_child(ready_go_instance)
	
	var player = $"Control/Isshin Ring/Player1"
	var boss = $"Control/Isshin Ring/Boss3"
	
	if ready_go_instance.has_signal("start_game"):
		ready_go_instance.start_game.connect(player.get_node("StateMachine/Idle")._on_start_game)
		ready_go_instance.start_game.connect(boss._on_start_game)
