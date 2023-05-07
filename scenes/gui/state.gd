extends CanvasLayer

onready var label = $Label

func _physics_process(delta):
	match Global.mario_state:
		0:
			label.text = "idle"
		1:
			label.text = "walk"
		2:
			label.text = "jump"
