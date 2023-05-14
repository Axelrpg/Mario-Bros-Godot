extends StaticBody2D

onready var animation = $AnimationPlayer

func _ready():
	animation.play("idle")

func blow():
	animation.play("blow")

func _on_DamageArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.blow()

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"blow":
			animation.play("idle")
