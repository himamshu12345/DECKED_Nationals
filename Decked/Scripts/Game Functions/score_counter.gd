extends Label

var game_over := false
var end_timer := 3.0

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	game_over = false
	end_timer = 3.0
	GameManager.score_updated.connect(update_losses)
	update_losses(
		GameManager.p1_losses,
		GameManager.p2_losses,
		GameManager.boss1_losses,
		GameManager.boss2_losses,
		GameManager.boss3_losses
	)

var menu_triggered := false

func _process(delta):
	if game_over and not menu_triggered:
		end_timer -= delta
		if end_timer <= 0:
			menu_triggered = true
			GameManager.reset_game()
			GameManager.go_to_level("Menu")

func update_losses(p1, p2, b1, b2, b3):
	if not game_over and GameManager.rounds > GameManager.max_rounds:
		trigger_game_over(p1, p2, b1, b2, b3)
		return
	match GameManager.current_mode:
		"2 Player":
			text = "P1: %d | P2: %d" % [p2, p1]
		"Joe":
			text = "P1: %d | Joe: %d" % [b1, p1]
		"Max":
			text = "P1: %d | Max: %d" % [b2, p1]
		"Isshin":
			text = "P1: %d | Isshin: %d" % [b3, p1]
		_:
			text = ""

func trigger_game_over(p1, p2, b1, b2, b3):
	game_over = true
	position.y += 125

	var winner := ""
	match GameManager.current_mode:
		"2 Player":
			if p1 == p2:
				winner = "It's a Tie!"
			elif p1 < p2:
				winner = "Player 1 Wins!"
			else:
				winner = "Player 2 Wins!"
		"Joe":
			winner = "Player 1 Wins!" if p1 < b1 else "Joe Wins!"
		"Max":
			winner = "Player 1 Wins!" if p1 < b2 else "Max Wins!"
		"Isshin":
			winner = "Player 1 Wins!" if p1 < b3 else "Isshin Wins!"

	text = winner
	
func reset_label():
	if game_over:
		position.y -= 125
	game_over = false
	end_timer = 3.0
	text = ""
