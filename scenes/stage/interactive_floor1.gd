extends StaticBody2D

onready var animation = $AnimationPlayer

func _ready():
	animation.play("idle")

func blow():
	animation.play("blow")
