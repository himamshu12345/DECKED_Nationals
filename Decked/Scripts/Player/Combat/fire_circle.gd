extends Node2D

var timer = 10.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("fire circle at ", global_position)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		print("Deleting fire Circle")
		queue_free()
