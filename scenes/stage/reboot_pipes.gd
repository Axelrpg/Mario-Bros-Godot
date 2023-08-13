extends Node2D

onready var left_animation = $LeftPipe/LeftAnimationPlayer
onready var right_animation = $RightPipe/RightAnimationPlayer

func _on_LeftAnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"reboot":
			left_animation.play("idle")


func _on_LeftJumpArea_body_entered(body):
	if body.is_in_group("enemy"):
		print("a")
		body.reboot()


func _on_LeftRebootArea_body_entered(body):
	if body.is_in_group("enemy"):
		left_animation.play("reboot")


func _on_LeftVanishingArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.queue_free()


func _on_RightJumpArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.reboot()


func _on_RightRebootArea_body_entered(body):
	if body.is_in_group("enemy"):
		right_animation.play("reboot")


func _on_RightVanishingArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.queue_free()
