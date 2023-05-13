extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var collision = $CollisionShape2D
onready var sprite = $Sprite

var state

enum {
	WALK,
	SPIN,
	VULNERABLE,
	DIE,
}

const FLOOR = Vector2(0,-1)
const GRAVITY = 16

var can_impulse = true
var can_spin = true
var can_vulnerable = true

var speed = -50

onready var motion = Vector2.ZERO


func _ready():
	state_ctrl(WALK)


func _physics_process(_delta):
	motion_ctrl()
	

func motion_ctrl():
	motion.y += GRAVITY
	
	if state == WALK:
		motion.x = speed
	elif state == VULNERABLE and is_on_floor():
		motion.x = 0
		
		
	if is_on_wall() and can_spin:
		can_spin = false
		spin_body()
		
	
	motion = move_and_slide(motion, FLOOR)
	

func state_ctrl(new_state):
	state = new_state
	
	match state:
		WALK:
			animation.play("walk")
		SPIN:
			animation.play("spin")
		VULNERABLE:
			animation.play("vulnerable")
			scale.y = -1
		DIE:
			animation.play("die2")
			
			
func impulse():
	motion.y -= 250
	yield(get_tree().create_timer(0.4), "timeout")
	can_impulse = true


func spin_body():
	state_ctrl(SPIN)
	
	
func spin_sprite():
	speed *= -1
	match sprite.flip_h:
		true:
			sprite.flip_h = false
		false:
			sprite.flip_h = true
	
	
func vulnerable():
	if can_impulse:
		print("a")
		can_impulse = false
		impulse()
		yield(get_tree().create_timer(0.1), "timeout")
		state_ctrl(VULNERABLE)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"spin":
			animation.play("spin2")
			spin_sprite()
		"spin2":
			state_ctrl(WALK)
			can_spin = true


func _on_DamageArea_body_entered(body):
	if body.is_in_group("player"):
		body.die()


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

