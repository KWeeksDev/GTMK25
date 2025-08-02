extends Node2D

# Things to complete
# Game Loop
# Scenes
# Array of gestures expected to do
var actions:Array[ActionResource] = []
var current_action := 0
var playback_speed := 1.0
var actions_completed := 0

var timer_refund := 2.0 # Amount of time added back to the timer when the gesture is successfully matched

@onready var gesture_zone := $Area2D
@onready var sfx_audio_player: AudioStreamPlayer = $SfxAudioPlayer
@onready var background_audio_player: AudioStreamPlayer = $BackgroundAudioPlayer
@onready var background_sprite: Sprite2D = $BackgroundSprite

var animation_sprite_instance


var start_menu_instance
var hud_instance

func _on_ready() -> void:
	# Default and typically final background
	background_sprite.texture = load("res://backgrounds/goto_sleep_scene.png")
	load_actions()
	# Setup callbacks for shapes drawn
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
		sfx_audio_player.stream = AudioStreamWAV.load_from_file("res://audio/matched.wav")
		sfx_audio_player.play()
		hud_instance.elapsed_time = min(hud_instance.elapsed_time - 5.0, 0.0)
		# Increase Score
		actions_completed += 1
		# Adjust Playbackspeed and Accuracy Threshold
		# Increment current action (looping if needed)
		current_action += 1
		if current_action >= actions.size(): current_action = 0
		handle_action()
	#else:
		#sfx_audio_player.stream = AudioStreamWAV.load_from_file("res://audio/mismatch.wav")
		#sfx_audio_player.play()
		
	
func _on_start_game():
	# Start Background Music
	background_audio_player.play()
	remove_child(start_menu_instance)
	# Load in HUD
	var hud_packed = load("res://scenes/hud/hud.tscn")
	hud_instance = hud_packed.instantiate()
	add_child(hud_instance)
	hud_instance.timer_ended.connect(_on_end_game)
	hud_instance.on_hud_element.connect(_on_hud_hover)
	gesture_zone.allow_drawing = true
	handle_action()
	print("game started")
	
func _on_end_game():	
	print("game ended with a score of: ", actions_completed)
	current_action = 0
	gesture_zone.target_template = actions[current_action].gesture_name
	gesture_zone.allow_drawing = false
	playback_speed = 1.0
	actions_completed = 0
	load_start_screen("PLAY AGAIN?")

func _on_hud_hover(is_on:bool):
	gesture_zone.allow_drawing = !is_on
	
# For Gamejam, load actions manually in set order
func load_actions():
	actions.append(load("res://actions/wake_up.tres"))
	actions.append(load("res://actions/stir_coffee.tres"))
	actions.append(load("res://actions/some_triangle.tres"))

# Handle all game logic for processing the current action
func handle_action():
	# Stop previous audio
	sfx_audio_player.stop()
	# Swap the background
	background_sprite.texture = load("res://backgrounds/wake_up_scene.png")
	# Unload the animation if existing
	if animation_sprite_instance != null: remove_child(animation_sprite_instance)
	# Load new animation if it exists
	if actions[current_action].sprite_animation != "":
		var animation_packed = load("res://animations/"+actions[current_action].sprite_animation)
		animation_sprite_instance = animation_packed.instantiate()
		add_child(animation_sprite_instance)
	# Set the current gesture that needs to be scored
	gesture_zone.target_template = actions[current_action].gesture_name
	# begin to player special sfx
	if actions[current_action].sfx_name != "":
		sfx_audio_player.stream = AudioStreamWAV.load_from_file("res://audio/"+actions[current_action].sfx_name)
		sfx_audio_player.play()
