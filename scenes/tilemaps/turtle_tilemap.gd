extends TileMap

export var Scene = preload("res://scenes/characters/enemies/turtle.tscn")

func _ready():
	instance_obstacles()
	
func instance_obstacles():
	var open_cells = get_used_cells()
	for i in open_cells:
		var scene = Scene.instance()
		scene.position = map_to_world(i)
		scene.position.x += 8
		scene.position.y += 6
		add_child(scene)
		set_cell(i.x, i.y, -1)
