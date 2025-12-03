extends Node3D
class_name Main



@export_category("References")
@export var player: PlayerController
@export var level: Level:
	set(value):
		level = value
		Global.curr_lvl = value

var lvl_number: int = 1



func _ready() -> void:
	Global.main = self
	Global.curr_lvl = level
	
	level.connect("lvl_over", Callable(self, "_on_level_over"), CONNECT_ONE_SHOT)



func _on_level_over() -> void:
	change_level()



func get_next_level_name() -> String:
	return "res://scenes/levels/level_" + str(lvl_number + 1) + ".tscn"

func change_level():
	var next_lvl_path: String = get_next_level_name()
	print(next_lvl_path)
	
	if level:
		level.queue_free()
		level = null
	
	var new_scene_res = load(next_lvl_path)
	var new_level = new_scene_res.instantiate()
	
	add_child(new_level)
	level = new_level
	
	if level:
		lvl_number += 1
		Global.curr_lvl = level
		level.connect("lvl_over", Callable(self, "_on_level_over"), CONNECT_ONE_SHOT)
