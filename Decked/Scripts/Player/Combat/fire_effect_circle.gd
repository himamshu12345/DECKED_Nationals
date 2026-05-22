extends Area2D

var players = []
var timers = []
var damage = 1
@export var damageRate = 0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for index in range(players.size()):
		timers[index] += delta
		if timers[index] >= damageRate:
			timers[index] = 0
			players[index].get_node_or_null("Health")._apply_damage(damage)


func _on_area_entered(area: Area2D) -> void:
	if area is HurtBox:
		players.append(area.owner)
		timers.append(0)


func _on_area_exited(area: Area2D) -> void:
	if area is HurtBox:
		var index = players.find(area.owner)
		players.remove_at(index)
		timers.remove_at(index)
		
