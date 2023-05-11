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
	RUN,
	DIE,
}

const FLOOR = Vector2(0,-1)
const GRAVITY = 16

var is_dying = false

var jump = 360
var min_jump = 360
var max_jump = 400

var speed = 100
var min_speed = 70
var max_speed = 140

onready var motion = Vector2.ZERO

func _physics_process(_delta):
	if is_dying == false:
		jump_ctrl()
		motion_ctrl()
		run_ctrl()
		
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
	
func run_ctrl():
	if is_on_floor():
		if Input.is_action_pressed(p1_run):
			if speed < max_speed:
				speed += 2
			if jump < max_jump:
				jump += 1
				
			if speed == max_speed:
				state_ctrl(RUN)
		else:
			if speed > min_speed:
				speed -= 2
			if jump > min_jump:
				jump -= 1
	
func state_ctrl(new_state):
	state = new_state
	
	if state != RUN:
		animation.playback_speed = 1
	
	match state:
		IDLE:
			animation.play("idle")
		WALK:
			animation.play("walk")
		JUMP:
			animation.play("jump")
		RUN:
			animation.playback_speed = 2
		DIE:
			animation.play("die")
			
func die():
	is_dying = true
	state_ctrl(DIE)

func _on_HeadArea_body_entered(body):
	if body.is_in_group("floor"):
		body.blow()


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"die":
			if get_tree().reload_current_scene() != OK:
				print("Fallo al recargar la escena")


func _on_Hitbox_body_entered(body):
	if body.is_in_group("enemy"):
		body.die(position)
