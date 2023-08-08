extends Node2D

export var spawn_time : int = 10

export var number_turtles : int = 3
export var maximum_enemies : int = 3

onready var left_animation = $LeftPipe/LeftAnimationPlayer
onready var left_position = $Positions/LeftPosition

onready var right_animation = $RightPipe/RightAnimationPlayer
onready var right_position = $Positions/RightPosition

onready var enemies = $Enemies

onready var timer = $SpawnTimer

var Turtle = load("res://scenes/characters/enemies/turtle.tscn")

func _ready():
	timer.wait_time = spawn_time
	timer.start()
	
	Global.turtle = number_turtles


func spawn_left():
	var turtle = Turtle.instance()
	turtle.position = left_position.position
	enemies.add_child(turtle)
	
	
func spawn_right():
	var turtle = Turtle.instance()
	turtle.position = right_position.position
	turtle.spin_sprite()
	enemies.add_child(turtle)


func _on_LeftAnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"active":
			left_animation.play("idle")
			spawn_left()


func _on_RightAnimationPlayer_animation_finished(anim_name):
	match anim_name:
		"active":
			right_animation.play("idle")
			spawn_right()


func _on_SpawnTimer_timeout():
	if Global.turtle > 0 and enemies.get_child_count() < maximum_enemies:
		var num = Global.random(1, 10)
		print(num)
		if num < 5:
			left_animation.play("active")
		else:
			right_animation.play("active")
