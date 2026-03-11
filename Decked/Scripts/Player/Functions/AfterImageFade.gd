extends Node2D

@export var lifetime := 0.25
var timer := 0.0

func _ready():
	for child in get_children():
		if child is CanvasItem:
			var tween = create_tween()
			tween.tween_property(child, "modulate:a", 0.0, lifetime)
	
	var timer_tween = create_tween()
	timer_tween.tween_interval(lifetime)
	timer_tween.tween_callback(queue_free)
