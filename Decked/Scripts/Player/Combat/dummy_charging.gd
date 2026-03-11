extends State
class_name DummyChargePunch

@export var animator: AnimatedSprite2D
@export var charge_audio: AudioStreamPlayer2D


const MAX_CHARGE_HITS := 2
var chargeHits = 0


func Enter():
	chargeHits = 0
	animator.play("ChargePunch")
	charge_audio.play()

func Update(_delta: float):
	pass

func on_charge_hit():
	chargeHits+=1
	if chargeHits >= MAX_CHARGE_HITS:
		break_charge()
		
func on_charge_interrupted():
	break_charge()

func break_charge():
	transition_state.emit(self, "QuickStagger")
