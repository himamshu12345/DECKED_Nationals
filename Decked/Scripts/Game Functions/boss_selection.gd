extends Control

func _ready():
	$HBoxContainer/JoeCard/Button.pressed.connect(func(): GameManager._on_joe_pressed())
	$HBoxContainer/MaxCard/Button.pressed.connect(func(): GameManager._on_max_pressed())
	$HBoxContainer/IsshinCard/Button.pressed.connect(func(): GameManager._on_isshin_pressed())
