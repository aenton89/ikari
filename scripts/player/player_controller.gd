extends Node3D
class_name PlayerController



@export_category("References")
@export var camera_controller: CameraController
@export var rotation_center: Marker3D

@onready var rotating: bool = false



func _ready() -> void:
	Global.player = self
	
	if rotation_center:
		camera_controller.target = rotation_center

func _input(event) -> void:
	if Input.is_action_just_pressed("exit"):
		get_tree().quit()
	
	if Input.is_action_just_pressed("click"):
		var mouse_pos = event.position
		
		var from: Vector3 = camera_controller.camera.project_ray_origin(mouse_pos)
		var to: Vector3 = from + camera_controller.camera.project_ray_normal(mouse_pos) * 1000.0
		
		var params: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.new()
		params.from = from
		params.to = to
		
		var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(params)
		
		if hit:
			var world_pos = hit.position
			var local_pos = Global.curr_lvl.grid_builder.to_local(world_pos)
			# używa normalnej, żeby wejść w blok a nie w powierzchnie
			var corrected_local = local_pos - hit.normal * (Global.curr_lvl.grid_builder.cell_size / 2.0)
			var cell = Global.curr_lvl.grid_builder.local_to_map(corrected_local)
			
			if Global.curr_lvl.remove_cell(cell):
				camera_controller.screen_shake(0.05, 4)
	
	if Input.is_action_just_pressed("view_rotate"):
		rotating = true
	elif Input.is_action_just_released("view_rotate"):
		rotating = false
		# snapuj do najbliższego ortogonalnego widoku
		camera_controller.snap_to_grid()
	
	# płynna rotacja podczas przeciągania
	if event is InputEventMouseMotion and rotating:
		camera_controller.rotate_by_delta(event.relative)
