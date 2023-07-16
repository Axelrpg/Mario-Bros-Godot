extends CanvasLayer

onready var label = $Label

func _physics_process(_delta):
	match Global_Mario.state:
		0:
			label.text = "idle"
		1:
			label.text = "walk"
		2:
			label.text = "jump"
		3:
			label.text = "run"
		4:
			label.text = "die"
