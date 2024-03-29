extends Node

onready var rng : RandomNumberGenerator = RandomNumberGenerator.new()

var is_last = false

func _physics_process(_delta):
	if Input.is_action_pressed("reset"):
		if get_tree().reload_current_scene() != OK:
			print("Error al recargar la escena")


func random(min_number, max_number):
	rng.randomize()
	var random = rng.randf_range(min_number, max_number)
	return random


func restart_last():
	is_last = false
