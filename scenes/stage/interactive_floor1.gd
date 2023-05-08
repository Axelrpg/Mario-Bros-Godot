extends StaticBody2D

onready var animation = $AnimationPlayer

func _ready():
	animation.play("idle")

func blow():
	animation.play("blow")

func _on_DamageArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.vulnerable()
