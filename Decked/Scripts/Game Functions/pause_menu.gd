extends Control


func _ready():
	visible = false
	get_tree().paused = false
	
func _on_resume_pressed() -> void:
	visible = false
	get_tree().paused = false	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		visible = !visible
		get_tree().paused = visible

	


func _on_menu_pressed() -> void:
	get_tree().paused = false
	GameManager.reset_game()
	GameManager.go_to_level("Menu")
