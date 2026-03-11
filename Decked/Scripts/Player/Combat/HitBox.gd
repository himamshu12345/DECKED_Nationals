class_name HitBox
extends Area2D

var damage: int = 0
var enabled := false

func enable():
	enabled = true
	monitoring = true
	
func disable():
	enabled = false
	monitoring = false
