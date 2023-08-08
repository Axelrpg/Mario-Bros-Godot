extends KinematicBody2D

var p1_left = "p1_left"
var p1_right = "p1_right"
var p1_down = "p1_down"
var p1_jump = "p1_jump"
var p1_run = "p1_run"

onready var animation = $AnimationPlayer
onready var sprite = $Sprite
onready var respawn_time = $RespawnTime

signal respawn

var state

enum {
	IDLE,
	WALK,
	JUMP,
	RUN,
	DIE,
	RESPAWN,
}

const FLOOR = Vector2(0, -1)
const GRAVITY = 16
const SNAP = Vector2(0, 5)

var is_dying = false
var on_floor = true

var respawn_animation = false

var jump = 360
var min_jump = 360
var max_jump = 400

#Velocidad minima = 70
#Velocidad maxima = 140
var max_speed = 70

var speed: float = 0.0
var friction: float = 150
var acceleration: float = 250

onready var motion = Vector2.ZERO


func _ready():
	state_ctrl(IDLE)


func _physics_process(delta):
	if is_dying == false:
		jump_ctrl()
		motion_ctrl(delta)
		run_ctrl()
		
	Global_Mario.state = state


func get_axis():
	var axis = Vector2.ZERO
	axis.x = int(Input.is_action_pressed(p1_right)) - int(Input.is_action_pressed(p1_left))
	return axis
			

func jump_ctrl():
	if is_on_floor():
		
		var axis = get_axis()
		
		if axis.x != 0:
			respawn_animation = false
			state_ctrl(WALK)
		elif axis.x == 0:
			if respawn_animation == false:
				state_ctrl(IDLE)
		
		if Input.is_action_pressed(p1_jump):
			on_floor = false
			motion.y -= jump
			
	else:
		respawn_animation = false
		state_ctrl(JUMP)


func motion_ctrl(delta):
	motion.y += GRAVITY
	
	var axis = get_axis()
	
	# Manejar la aceleración
	if axis.x == 1:
		sprite.flip_h = false
		speed += acceleration * delta
	elif axis.x == -1:
		sprite.flip_h = true
		speed -= acceleration * delta

	# Aplicar fricción
	if speed > 0:
		speed = max(0, speed - friction * delta)
	elif speed < 0:
		speed = min(0, speed + friction * delta)

	# Limitar la velocidad máxima
	speed = clamp(speed, -max_speed, max_speed)
	motion.x = speed

	motion = move_and_slide_with_snap(motion, SNAP, FLOOR)


func run_ctrl():
	if is_on_floor():
		if Input.is_action_pressed(p1_left) || Input.is_action_pressed(p1_right):
			if Input.is_action_pressed(p1_run):
				if max_speed < 140:
					max_speed += 2
				
				if max_speed > 105:
					jump = max_jump
			else:
				if max_speed > 70:
					max_speed -= 2
				
				if max_speed < 105:
					jump = min_jump
	

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
		RESPAWN:
			animation.play("respawn")


func activate_respawn_animation():
	respawn_animation = true
	state_ctrl(RESPAWN)


func die():
	is_dying = true
	state_ctrl(DIE)


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"die":
			if Global_Mario.lives > 0:
				Global_Mario.lives -= 1
				respawn_time.start()
			else:
				if get_tree().reload_current_scene() != OK:
					print("Error al recargar la escena")


func _on_DamageArea_body_entered(body):
	if body.is_in_group("enemy"):
		body.die(position)


func _on_FloorArea_body_entered(body):
	if body.is_in_group("floor"):
		on_floor = true


func _on_HeadArea_body_entered(body):
	if body.is_in_group("floor"):
		body.blow()


func _on_RespawnTime_timeout():
	emit_signal("respawn")
	queue_free()
