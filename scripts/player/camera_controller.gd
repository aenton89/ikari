extends Node3D
class_name CameraController



@export_category("References")
@export var camera: Camera3D
@export_category("Rotation Related")
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
var rotate_tween: Tween
# i tween do
var shake_tween: Tween
var is_shaking := false
var shake_original_pos: Vector3



func _ready() -> void:
	camera.position.z = camera_distance
	rotation_degrees = target_rotation



func screen_shake(magnitude: float, amount: int) -> void:
	# jeśli już trwa – reset
	if is_shaking:
		shake_tween.kill()
		camera.position = shake_original_pos
	
	is_shaking = true
	shake_original_pos = camera.position
	
	shake_tween = create_tween()
	shake_tween.set_trans(Tween.TRANS_SINE)
	shake_tween.set_ease(Tween.EASE_OUT)
	
	for i in range(amount):
		var offset = Vector3(
			randf_range(-magnitude, magnitude),
			randf_range(-magnitude, magnitude),
			0
		)
		shake_tween.tween_property(camera, "position", shake_original_pos + offset, 0.03)
	
	# powrót do normalnej pozycji
	shake_tween.tween_property(camera, "position", shake_original_pos, 0.05)
	
	# koniec efektu
	shake_tween.finished.connect(func():
		is_shaking = false
	)

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
	if rotate_tween and rotate_tween.is_running():
		rotate_tween.kill()
	
	rotate_tween = create_tween()
	rotate_tween.set_trans(Tween.TRANS_CUBIC)
	rotate_tween.set_ease(Tween.EASE_OUT)
	rotate_tween.tween_property(self, "rotation_degrees", snapped_rot, tween_length)
	
	# aktualizowanie targetu na snapowaną wartość
	target_rotation = snapped_rot
