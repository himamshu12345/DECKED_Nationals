extends Node2D


func _ready():
	MenuMusic.stop_music()
	GameManager.current_mode = "2 Player"
	
	var ready_go_sprite := $"Control/Boxing Ring/StartGame"
	var player1 := $"Control/Boxing Ring/Player1"
	var player2 := $"Control/Boxing Ring/Player2"
	
	if ready_go_sprite == null:
		print("ERROR: ReadyGo node not found!")
		return
		
	if player1:
		ready_go_sprite.start_game.connect(player1.get_node("StateMachine/Idle")._on_start_game)
	if player2:
		ready_go_sprite.start_game.connect(player2.get_node("StateMachine/Idle")._on_start_game)
