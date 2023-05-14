extends KinematicBody2D

onready var animation = $AnimationPlayer
onready var collision = $CollisionShape2D
onready var sprite = $Sprite
onready var vulnerable_time = $VulnerableTime

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
	
	if state == WALK || state == DIE:
		motion.x = speed
	elif state == VULNERABLE and is_on_floor():
		motion.x = 0
		
		
	if is_on_wall() and can_spin and state == WALK:
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
			vulnerable_time.start()
		DIE:
			animation.play("die")
			
			
func blow():
	if can_impulse:
		can_impulse = false
		impulse()
		yield(get_tree().create_timer(0.1), "timeout")
		match state:
			WALK:
				state_ctrl(VULNERABLE)
				scale.y *= -1
			VULNERABLE:
				state_ctrl(WALK)
				scale.y *= -1


func die(player_position : Vector2):
	if state == VULNERABLE:
		impulse()
		state_ctrl(DIE)
		match sprite.flip_h:
			false:
				if player_position.x < position.x:
					speed *= -1
			true:
				if player_position.x > position.x:
					speed *= -1


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


func _on_VulnerableTime_timeout():
	blow()
