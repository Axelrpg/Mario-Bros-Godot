extends TileMap

export var Scene = preload("res://scenes/stage/interactive_floor1.tscn")

func _ready():
	instance_obstacles()
	
func instance_obstacles():
	var open_cells = get_used_cells()
	for i in open_cells:
		var scene = Scene.instance()
		scene.position = map_to_world(i)
		scene.position.x += 4
		scene.position.y += 2
		add_child(scene)
		set_cell(i.x, i.y, -1)
