extends AnimatedSprite2D

@export var animations: Array[String]
var current_animation:= 0

func _on_ready() -> void:
	play(animations[current_animation])

func _on_animation_finished() -> void:
	current_animation += 1
	if current_animation >= animations.size(): pass
	play(animations[current_animation])
