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

var can_spin = true
var can_vulnerable = true

var speed = 50

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
		VULNERABLE:
			animation.play("vulnerable")
		DIE:
			animation.play("die2")
			
func die(player_position):
	if state == VULNERABLE:
		if player_position.x > position.x and sprite.flip_h:
			speed *= -1
		elif player_position.x < position.x and sprite.flip_h == false:
			speed *= -1
		
		impulse()
		state_ctrl(DIE)
		
func flip_sprite(value: bool):
	match value:
		true:
			scale.x = 1
			speed *= 1
		false:
			scale.x = -1
			speed *= -1
			
func impulse():
	motion.y -= 250
			
func spin_body():
	match scale.x:
		1.0:
			scale.x *= -1
		-1.0:
			scale.x *= -1
			
func spin_motion():
	speed *= -1
	state_ctrl(SPIN)
	
func vulnerable():
	if can_vulnerable:
		can_vulnerable = false
		if state == WALK:
			impulse()
			yield(get_tree().create_timer(0.1),"timeout")
			state_ctrl(VULNERABLE)
		elif state == VULNERABLE:
			impulse()
			yield(get_tree().create_timer(0.1),"timeout")
			state_ctrl(WALK)
		yield(get_tree().create_timer(0.45),"timeout")
		can_vulnerable = true
		
func wait_time(time : int):
	yield(get_tree().create_timer(time),"timeout")

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

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()
