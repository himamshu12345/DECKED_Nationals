extends Button

func _ready():
	modulate = Color(1, 0, 0, 0.8) # Red shadow
	position += Vector2(5, 5) # Offset
	mouse_filter = Control.MOUSE_FILTER_IGNORE
