class_name DoubleTapDetector

const WINDOW := 0.25

var _last_press: Dictionary = {}

func setup(actions: Array[String]) -> void:
	for a in actions:
		_last_press[a] = -999.0

func check(actions: Array[String]) -> String:
	var now := Time.get_ticks_msec() / 1000.0
	for a in actions:
		if Input.is_action_just_pressed(a):
			var last: float = _last_press.get(a, -999.0)  # explicit float type
			_last_press[a] = now
			if now - last <= WINDOW:
				return a
	return ""
