extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var sprite = $Sprite

var state

enum {
	WALK,
	SPIN
}

const FLOOR = Vector2(0,-1)
const GRAVITY = 16

var can_spin = true

var speed = 50

onready var motion = Vector2.ZERO

func _ready():
	state_ctrl(WALK)

func _physics_process(delta):
	motion_ctrl()
	
func motion_ctrl():
	motion.y += GRAVITY
	
	if state == WALK:
		motion.x = speed
	
	if is_on_wall():
		if can_spin:
			can_spin = false
			spin_motion()
		
	motion = move_and_slide(motion, FLOOR)
	
func state_ctrl(new_state):
	state = new_state
	
	match state:
		WALK:
			animation.play("walk")
		SPIN:
			animation.play("spin")
			
func spin_body():
	match scale.x:
		1.0:
			scale.x *= -1
		-1.0:
			scale.x *= -1
			
func spin_motion():
	speed *= -1
	state_ctrl(SPIN)

func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"spin":
			animation.play("spin2")
			spin_body()
		"spin2":
			can_spin = true
			state_ctrl(WALK)

func _on_DamageArea_body_entered(body):
	if body.is_in_group("player"):
		body.die()