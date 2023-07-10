extends StaticBody2D

onready var animation = $AnimationPlayer

func _ready():
	animation.play("active")


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"active":
			queue_free()
