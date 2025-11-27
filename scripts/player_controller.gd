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
	
	if Input.is_action_just_pressed("view_rotate"):
		rotating = true
	elif Input.is_action_just_released("view_rotate"):
		rotating = false
		# snapuj do najbliższego ortogonalnego widoku
		camera_controller.snap_to_grid()
	
	# płynna rotacja podczas przeciągania
	if event is InputEventMouseMotion and rotating:
		camera_controller.rotate_by_delta(event.relative)
