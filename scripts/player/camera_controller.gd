extends Node3D
class_name CameraController



@export_category("References")
@export var camera: Camera3D
@export_category("Values")
@export var tween_length: float = 0.3
@export var camera_distance: float = 5.0
@export var mouse_sensitivity: float = 0.3

# kąty docelowe - snapowane do wielokrotności 90 stopni
@onready var target_rotation: Vector3 = Vector3.ZERO

# rotation_center from player
var target: Marker3D:
	set(value):
		target = value
		global_position = value.global_position
# tween do obrotu
var tween: Tween



func _ready() -> void:
	camera.position.z = camera_distance
	rotation_degrees = target_rotation



func rotate_by_delta(delta: Vector2) -> void:
	# ruch myszy na rotację (w stopniach)
	var rotation_delta: Vector3 = Vector3(
		-delta.y * mouse_sensitivity,
		-delta.x * mouse_sensitivity,
		0
	)
	
	# dodaj do obecnej rotacji
	target_rotation += rotation_delta
	
	# normalizuj obie osie do [-180, 180] - pełna swoboda obrotu
	# X i Y
	for i in [0, 1]:
		target_rotation[i] = fmod(target_rotation[i], 360.0)
		if target_rotation[i] > 180:
			target_rotation[i] -= 360
		elif target_rotation[i] < -180:
			target_rotation[i] += 360
	
	# płynna rotacja w czasie rzeczywistym (bez tweena)
	rotation_degrees = target_rotation

func snap_to_grid() -> void:
	# snapuj do najbliższej wielokrotności 90 stopni
	var snapped_rot: Vector3 = Vector3(
		round(target_rotation.x / 90.0) * 90.0,
		round(target_rotation.y / 90.0) * 90.0,
		0
	)
	
	# znajdź najkrótszą drogę dla każdej z osi
	var current: Vector3 = rotation_degrees
	for i in [0, 1]:  # X i Y
		var diff: float = snapped_rot[i] - current[i]
		
		# jeśli różnica > 180 stopni, idź w drugą strone - bo obrót się buguje i robi 360
		if diff > 180:
			current[i] += 360
		elif diff < -180:
			current[i] -= 360
	
	# starting point dla tweena
	rotation_degrees = current
	
	# animacja do snapowanej pozycji
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "rotation_degrees", snapped_rot, tween_length)
	
	# aktualizowanie targetu na snapowaną wartość
	target_rotation = snapped_rot
