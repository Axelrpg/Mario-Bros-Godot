extends CanvasLayer

onready var label = $Mario
onready var turtle = $Turtle

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
			
	match Global_Turtle.state:
		0:
			turtle.text = "walk"
		1:
			turtle.text = "spin"
		2:
			turtle.text = "vulnerable"
		3:
			turtle.text = "die"
