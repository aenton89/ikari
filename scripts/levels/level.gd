extends Node3D
class_name Level



signal lvl_over()

@export_category("References")
@export var grid_builder: GridMap

@onready var cell_map: Dictionary[Vector3i, Dictionary] = {}



func _ready() -> void:
	rebuild_cell_map()

func _physics_process(delta: float) -> void:
	if cell_map.is_empty():
		emit_signal("lvl_over")



func rebuild_cell_map():
	cell_map.clear()
	var lib: MeshLibrary = grid_builder.mesh_library
	
	for cell_pos in grid_builder.get_used_cells():
		var item_id = grid_builder.get_cell_item(cell_pos)
		
		cell_map[cell_pos] = {
			"item_id": item_id,
			"item_name": lib.get_item_name(item_id)
		}

func get_cell_info(cell_pos: Vector3i) -> Dictionary[Vector3i, Dictionary]:
	return cell_map.get(cell_pos)

func remove_cell(cell_pos: Vector3i):
	if cell_map.has(cell_pos):
		cell_map.erase(cell_pos)
		grid_builder.set_cell_item(cell_pos, -1)
