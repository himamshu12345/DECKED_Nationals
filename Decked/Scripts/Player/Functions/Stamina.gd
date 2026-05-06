class_name Stamina
extends Node

@export var max_stamina: float = 100.0
@export var base_regen_rate: float = 15.0
@export var boosted_regen_rate: float = 35.0
@export var boosted_regen_duration: float = 3.0

const COST_PUNCH: float = 8.0
const COST_BLOCK: float = 10.0
const COST_DASH: float = 20.0
const COST_CHARGE_PER_SEC: float = 12.0

var current_stamina: float
var is_exhausted: bool = false
var _boost_timer: float = 0.0
var _regen_paused: bool = false

signal stamina_changed(current: float, maximum: float)
signal stamina_exhausted
signal stamina_recovered

func _ready() -> void:
	current_stamina = max_stamina
	stamina_changed.emit(current_stamina, max_stamina)

func _process(delta: float) -> void:
	if _regen_paused:
		return

	var regen = boosted_regen_rate if _boost_timer > 0.0 else base_regen_rate

	if _boost_timer > 0.0:
		_boost_timer -= delta
		if _boost_timer <= 0.0:
			_boost_timer = 0.0
			stamina_recovered.emit()

	if current_stamina < max_stamina:
		current_stamina = minf(current_stamina + regen * delta, max_stamina)
		stamina_changed.emit(current_stamina, max_stamina)

	# Clear exhaustion flag once stamina is meaningfully restored
	if is_exhausted and current_stamina > 5.0:
		is_exhausted = false

func consume(amount: float) -> void:
	if is_exhausted:
		return
	current_stamina = maxf(current_stamina - amount, 0.0)
	stamina_changed.emit(current_stamina, max_stamina)
	if current_stamina <= 0.0 and not is_exhausted:
		is_exhausted = true
		_boost_timer = boosted_regen_duration
		stamina_exhausted.emit()

func pause_regen(paused: bool) -> void:
	_regen_paused = paused

func is_ready() -> bool:
	return not is_exhausted
