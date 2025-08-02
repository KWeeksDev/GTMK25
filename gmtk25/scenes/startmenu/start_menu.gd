extends MarginContainer

@export var button_text:String = "START"
signal start_game;
@onready var start_button: Button = $HBoxContainer/HBoxContainer/VBoxContainer/StartButton

func _on_ready() -> void:
	start_button.text = button_text

func _on_button_pressed() -> void:
	emit_signal("start_game")
