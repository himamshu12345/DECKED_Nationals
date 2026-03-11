extends State
class_name DummyIdle

@export var player : AnimatedSprite2D
var is_active := false


func Enter():
	player.play("Idle")

func Update(_delta: float):
	if owner.name == "Dummy_Shield":
		transition_state.emit(self, "DummyShield")
	if owner.name == "Dummy_Charging":
		transition_state.emit(self, "DummyCharging")

func on_idle_hit():
	transition_state.emit(self, "QuickStagger")

func on_charge_hit():
	transition_state.emit(self, "ConfusedStaggered")
