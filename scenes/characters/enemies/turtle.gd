extends KinematicBody2D

export var speed: int = 25

onready var adjust_state = $AdjustState
onready var animation = $AnimationPlayer
onready var collision = $CollisionShape2D
onready var hit_area = $HitArea/HitCollision
onready var sprite = $Sprite
onready var timer_impulse = $TimerImpulse
onready var vulnerable_time = $VulnerableTime

var state

enum {
	WALK,
	SPIN,
	VULNERABLE,
	DIE,
	REBOOT,
}

var skin

enum {
	RED,
	GREEN,
	BLUE
}

const FLOOR = Vector2(0, -1)
const GRAVITY = 16

var can_impulse = true
var can_spin = true
var can_vulnerable = true

var is_last = false

var speed_red
var speed_green
var speed_blue

onready var motion = Vector2.ZERO


func _ready():
	skin_ctrl(RED)
	state_ctrl(WALK)
	set_speeds()


func _physics_process(_delta):
	motion_ctrl()
	
	Global_Turtle.state = state
	
	if Global.is_last == true and is_last == false:
		is_last = true
		skin_ctrl(BLUE)


func motion_ctrl():
	motion.y += GRAVITY
	
	if state == VULNERABLE and is_on_floor():
		motion.x = 0
	elif state == WALK and is_on_floor():
		motion.x = speed
		
		
	if is_on_wall() and can_spin and state == WALK:
		spin_body()
		
	
	motion = move_and_slide(motion, FLOOR, true)


func skin_ctrl(new_skin):
	skin = new_skin
	
	match skin:
		RED:
			sprite.texture = load("res://sprites/characters/enemies/turtle_red.png")
		GREEN:
			sprite.texture = load("res://sprites/characters/enemies/turtle_green.png")
			
			if speed > 0:
				speed = speed_green
			else:
				speed = -speed_green
		BLUE:
			sprite.texture = load("res://sprites/characters/enemies/turtle_blue.png")
			
			if speed > 0:
				speed = speed_blue
			else:
				speed = -speed_blue


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
		REBOOT:
			animation.play("reboot")


func blow(blow_position : Vector2):
	if can_impulse:
		can_impulse = false
		
		match state:
			WALK:
				if blow_position.x < position.x:
					impulse_walk(1)
				elif blow_position.x > position.x:
					impulse_walk(-1)
				else:
					impulse()
			VULNERABLE:
				if blow_position.x < position.x:
					impulse_vulnerable(1)
				elif blow_position.x > position.x:
					impulse_vulnerable(-1)
				else:
					impulse()
		
		adjust_state.start()


func change_to_blue():
	skin_ctrl(BLUE)


func die(player_position : Vector2):
	if state == VULNERABLE:
		state_ctrl(DIE)
		
		if player_position.x < position.x:
			impulse_die(1)
		else:
			impulse_die(-1)
			
			
func impulse():
	if is_on_floor():
		motion.y -= 225
	else:
		motion.y -= 550
	
	timer_impulse.start()


func impulse_die(value : int):
	match value:
		1:
			motion.x += 50
		-1:
			motion.x -= 50
	
	impulse()


func impulse_vulnerable(value : int):
	match value:
		1:
			motion.x += 50
			sprite.flip_h = true
			
			if speed > 0:
				pass
			else:
				speed *= -1
		-1:
			motion.x -= 50
			sprite.flip_h = false
			
			if speed > 0:
				speed *= -1
			else:
				pass
			
	impulse()


func impulse_walk(value : int):
	match value:
		1:
			match sprite.flip_h:
				true:
					pass
				false:
					spin_sprite()
					motion.x += 50
		-1:
			match sprite.flip_h:
				true:
					spin_sprite()
					motion.x -= 50
				false:
					pass
	
	impulse()


func reboot():
	state_ctrl(REBOOT)
	
	match skin:
		RED:
			motion.y -= 200
		GREEN:
			motion.y -= 175
		BLUE:
			motion.y -= 150
	
	if speed > 0:
		speed = 50
	else:
		speed = -50
		
	Global_Turtle.cont += 1


func set_speeds():
	speed_red = speed
	speed_green = speed * 2
	speed_blue = speed * 3


func spin_body():
	can_spin = false
	state_ctrl(SPIN)
	
	
func spin_sprite():
	speed *= -1
	
	match $Sprite.flip_h:
		true:
			$Sprite.flip_h = false
		false:
			$Sprite.flip_h = true


func _on_AdjustState_timeout():
	match state:
			WALK:
				state_ctrl(VULNERABLE)
				scale.y *= -1
			VULNERABLE:
				state_ctrl(WALK)
				scale.y *= -1


func _on_AnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"spin":
			animation.play("spin2")
			spin_sprite()
		"spin2":
			state_ctrl(WALK)
			can_spin = true


func _on_DisableCollision_timeout():
	set_collision_mask_bit(4, false)
	
	
func _on_HitArea_body_entered(body):
	if body.is_in_group("player"):
		body.die()


func _on_TimerImpulse_timeout():
	can_impulse = true


func _on_VulnerableTime_timeout():
	if state == VULNERABLE:
		blow(position)
	
	if skin == RED and state == VULNERABLE:
		skin_ctrl(GREEN)
