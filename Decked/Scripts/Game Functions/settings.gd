extends Control

@onready var volume_slider = $VolumeOptions/Volume

func _ready() -> void:
	var current_db = AudioServer.get_bus_volume_db(0)
	var linear = db_to_linear(current_db)
	volume_slider.value = linear

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_check_box_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)
