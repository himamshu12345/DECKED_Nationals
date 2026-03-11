extends CharacterBody2D

@onready var opponent: CharacterBody2D = null


func _ready():
	add_to_group("players")

func _physics_process(delta: float) -> void:
	if opponent == null:
		_find_opponent()
		
	if opponent != null:
		var direction = (opponent.global_position - global_position).normalized()
		rotation = direction.angle() + PI / 2
	
func _find_opponent() -> void:
	var players = get_tree().get_nodes_in_group("players")
	for p in players:
		if p != self and p is CharacterBody2D:
			opponent = p
			break
	var enemies = get_tree().get_nodes_in_group("enemies")
	for e in enemies:
		if e != self and e is CharacterBody2D:
			opponent = e
			break
