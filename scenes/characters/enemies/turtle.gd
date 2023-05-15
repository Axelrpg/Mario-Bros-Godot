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

var speed = 50

onready var motion = Vector2.ZERO


func _ready():
	state_ctrl(WALK)
	yield(get_tree().create_timer(1), "timeout")
	set_collision_layer_bit(4, false)
	set_collision_mask_bit(4, false)


func _physics_process(_delta):
	motion_ctrl()
	

func motion_ctrl():
	motion.y += GRAVITY
	
	if state == VULNERABLE and is_on_floor():
		motion.x = 0
		
		
	if is_on_wall() and can_spin and state == WALK:
		can_spin = false
		spin_body()
		
	
	motion = move_and_slide(motion, FLOOR)
	

func state_ctrl(new_state):
	state = new_state
	
	match state:
		WALK:
			motion.x = speed
			animation.play("walk")
		SPIN:
			animation.play("spin")
		VULNERABLE:
			animation.play("vulnerable")
			vulnerable_time.start()
		DIE:
			animation.play("die")
			Global.turtle -= 1
			
			
func blow(blow_position : Vector2):
	if can_impulse:
		can_impulse = false
		
		match state:
			WALK:
				if blow_position.x < position.x:
					impulse_walk(1)
				else:
					impulse_walk(-1)
			VULNERABLE:
				if blow_position.x < position.x:
					impulse_vulnerable(1)
				elif blow_position.x > position.x:
					impulse_vulnerable(-1)
				else:
					impulse()
		
		yield(get_tree().create_timer(0.1), "timeout")
		
		match state:
			WALK:
				state_ctrl(VULNERABLE)
				scale.y *= -1
			VULNERABLE:
				state_ctrl(WALK)
				scale.y *= -1

func change_direction():
	speed *= -1


func die(player_position : Vector2):
	if state == VULNERABLE:
		state_ctrl(DIE)
		
		if player_position.x < position.x:
			impulse_die(1)
		else:
			impulse_die(-1)
			
			
func impulse():
	motion.y -= 225
	yield(get_tree().create_timer(0.5), "timeout")
	can_impulse = true


func impulse_die(value : int):
	match value:
		1:
			motion.x += 100
		-1:
			motion.x -= 100
	
	motion.y -= 225


func impulse_vulnerable(value : int):
	match value:
		1:
			motion.x += 100
			speed = 50
			sprite.flip_h = true
		-1:
			motion.x -= 100
			speed = -50
			sprite.flip_h = false
			
	impulse()


func impulse_walk(value : int):
	match value:
		1:
			match sprite.flip_h:
				true:
					pass
				false:
					motion.x += 100
		-1:
			match sprite.flip_h:
				true:
					motion.x -= 100
				false:
					pass
	
	impulse()


func spin_body():
	state_ctrl(SPIN)
	
	
func spin_sprite():
	speed *= -1
	match $Sprite.flip_h:
		true:
			$Sprite.flip_h = false
		false:
			$Sprite.flip_h = true


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
	blow(position)
