extends Node

var mario_state

func _physics_process(_delta):
	if Input.is_action_pressed("reset"):
		if get_tree().reload_current_scene() != OK:
			print("Error al recargar la escena")
