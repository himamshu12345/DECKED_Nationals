class_name HitBox
extends Area2D

var damage: int = 0
var enabled := false
@export var knockback_multiplier: float = 10.0  # tune per-attack in the Inspector

func get_knockback_force() -> float:
	return damage * knockback_multiplier

func enable():
	enabled = true
	monitoring = true
	
func disable():
	enabled = false
	monitoring = false
