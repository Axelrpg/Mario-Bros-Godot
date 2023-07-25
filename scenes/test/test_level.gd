extends Node2D

var Mario = load("res://scenes/characters/mario/mario.tscn")
var SpawnPlatform = load("res://scenes/stage/spawn_platform.tscn")

export var mario_lives : int = 3

onready var spawn_left = $Spawns/SpawnLeft

func _ready():
	Global_Mario.lives = mario_lives
	
	connect_signal()


func connect_signal():
	# Conectar la señal "respawn" al método "_on_respawn"
	var mario = get_node("Mario")
	mario.connect("respawn", self, "_on_respawn")


func _on_respawn():
	var mario = Mario.instance()
	mario.position = Vector2(spawn_left.position.x, spawn_left.position.y - 8)
	mario.connect("respawn", self, "_on_respawn")
	add_child(mario)
	
	var spawn_platform = SpawnPlatform.instance()
	spawn_platform.position = spawn_left.position
	add_child(spawn_platform)
