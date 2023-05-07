extends KinematicBody2D

var p1_left = "p1_left"
var p1_right = "p1_right"
var p1_down = "p1_down"
var p1_jump = "p1_jump"
var p1_run = "p1_run"

onready var animation = $AnimationPlayer
onready var sprite = $Sprite

var state

enum {
	IDLE,
	WALK,
	JUMP,
	BEND
}

const FLOOR = Vector2(0,-1)
const GRAVITY = 16

var jump = 360

var speed = 100

onready var motion = Vector2.ZERO

func _physics_process(delta):
	jump_ctrl()
	motion_ctrl()
	Global.mario_state = state
	
func get_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed(p1_right)) - int(Input.is_action_pressed(p1_left))
	return axis
			
func jump_ctrl():
	if is_on_floor():
		
		var axis = Vector2.ZERO
		axis = get_axis()
		
		if axis.x != 0:
			state_ctrl(WALK)
		else:
			state_ctrl(IDLE)
		
		if Input.is_action_pressed(p1_jump):
			motion.y -= jump
			
	else:
		state_ctrl(JUMP)
	
func motion_ctrl():
	motion.y += GRAVITY
	
	var axis = get_axis()
		
	if axis.x == 1:
		sprite.flip_h = false
	elif axis.x == -1:
		sprite.flip_h = true
		
	if axis.x != 0:
		motion.x = axis.x * speed
	else:
		motion.x = 0
		
	motion = move_and_slide(motion, FLOOR)
	
func state_ctrl(new_state):
	state = new_state
	
	match state:
		IDLE:
			animation.play("idle")
		WALK:
			animation.play("walk")
		JUMP:
			animation.play("jump")
		BEND:
			animation.play("bend")

func _on_HeadArea_body_entered(body):
	if body.is_in_group("floor"):
		body.blow()
