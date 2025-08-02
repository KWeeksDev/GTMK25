extends CanvasLayer

@onready var timer := $GameTimer
@onready var bar := $GameTimerBar

signal timer_ended

var total_time := 30.0
var elapsed_time := 0.0
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
