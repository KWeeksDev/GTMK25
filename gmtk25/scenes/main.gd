extends Node2D

# Things to complete
# Game Loop
# Scenes
# Array of gestures expected to do
var actions:Array[ActionResource] = []
var current_action := 0
var playback_speed := 1.0
var actions_completed := 0

@onready var gesture_zone := $Area2D

var start_menu_instance
var hud_instance

func _on_ready() -> void:
	load_actions()
	# Setup callbacks for shapes drawn
	gesture_zone.target_template = actions[current_action].gesture_name
	gesture_zone.shape_matched.connect(_on_shape_matched)
	load_start_screen("START")

func load_start_screen(button_name:String):
	# Load the start screen
	var start_menu_packed = load("res://scenes/startmenu/start_menu.tscn")
	start_menu_instance = start_menu_packed.instantiate()
	# Lazy hack, after completing the game once the "Start" button becomes "Play Again?"
	start_menu_instance.button_text = button_name
	add_child(start_menu_instance)
	start_menu_instance.start_game.connect(_on_start_game)
	
func _on_shape_matched(matched:bool):
	if matched:
		# Increase Score
		actions_completed += 1
		# Adjust Playbackspeed and Accuracy Threshold
		# Increment current action (looping if needed)
		current_action += 1
		if current_action >= actions.size(): current_action = 0
		gesture_zone.target_template = actions[current_action].gesture_name
	
func _on_start_game():
	remove_child(start_menu_instance)
	# Load in HUD
	var hud_packed = load("res://scenes/hud/hud.tscn")
	hud_instance = hud_packed.instantiate()
	add_child(hud_instance)
	hud_instance.timer_ended.connect(_on_end_game)
	gesture_zone.allow_drawing = true
	print("game started")
	
func _on_end_game():	
	print("game ended with a score of: ", actions_completed)
	current_action = 0
	gesture_zone.target_template = actions[current_action].gesture_name
	gesture_zone.allow_drawing = false
	playback_speed = 1.0
	actions_completed = 0
	load_start_screen("PLAY AGAIN?")
	
# For Gamejam, load actions manually in set order
func load_actions():
	actions.append(load("res://actions/wake_up.tres"))
	actions.append(load("res://actions/stir_coffee.tres"))
	actions.append(load("res://actions/some_triangle.tres"))
