class_name HitBox
extends Area2D

var damage: int = 0
var enabled := false
@export var knockback_multiplier: float = 10.0  # tune per-attack in the Inspector

#Add to boss
var buffs


func _ready() -> void:
	buffs = owner.get_node_or_null("Buffs")

func get_knockback_force() -> float:
	var knockback = damage * knockback_multiplier *  buffs.knockback_buff * buffs.explosion * buffs.explosion * buffs.explosion 
	return knockback + owner.get_node_or_null("Health").max_health * buffs.bulldozer/5

func enable():
	enabled = true
	monitoring = true
	
func disable():
	enabled = false
	monitoring = false
