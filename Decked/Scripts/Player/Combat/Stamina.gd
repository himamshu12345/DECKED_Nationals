class_name  Stamina
extends Node

@export var max_stamina: float = 100.0
@export var base_regen_rate: float = 15.0 


const COST_PUNCH := 10
const COST_BLOCK := 10
const COST_DASH := 20.0
const COST_CHARGE := 12.0

var current_stamina: float
var is_exhausted: bool = false
var _boost_timer: float = 0.0
var _regen_paused: bool = false

signal stamina_changed(current: float, maximum: float)
signal stamina_exhausted
signal stamina_recovered
