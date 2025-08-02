extends CanvasLayer

@onready var timer := $GameTimer
@onready var bar := $GameTimerBar
@onready var book_sprite: Sprite2D = $BookSprite
@onready var book_button: Button = $BookButton
@onready var icon_button: TextureButton = $IconButton

signal timer_ended
signal on_hud_element(is_on:bool)

var total_time := 130.0
@export var elapsed_time := 0.0
var is_running := false

func _ready() -> void:
	bar.max_value = total_time
	bar.value = total_time
	timer.wait_time = 1
	timer.timeout.connect(_on_timer_tick)
	timer.start()
	is_running = true
	
func _on_timer_tick():
	if not is_running:
		return
	
	elapsed_time += timer.wait_time
	var remaining = max(total_time - elapsed_time, 0)
	bar.value = remaining
	
	if remaining <= 0:
		is_running = false
		timer.stop()
		# Goto the end screen
		emit_signal("timer_ended")
		print("Timer Done")
		
func pauseTimer():
	timer.stop()

func resumeTimer():
	timer.start()

func _on_texture_button_pressed() -> void:
	book_sprite.visible = true
	book_button.visible = true

func _on_book_button_mouse_entered() -> void:
	emit_signal("on_hud_element",true)

func _on_book_button_mouse_exited() -> void:
	emit_signal("on_hud_element",false)

func _on_icon_button_mouse_entered() -> void:
	emit_signal("on_hud_element",true)

func _on_icon_button_mouse_exited() -> void:
	emit_signal("on_hud_element",false)


func _on_book_button_pressed() -> void:
	book_sprite.visible = false
	book_button.visible = false
