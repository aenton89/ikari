extends Control
class_name TimerUI



@export_category("References")
@export var text: Label

var elapsed_time: float = 0.0
var running: bool = false



func _ready() -> void:
	reset_timer()
	start_timer()

func _process(delta: float) -> void:
	if running:
		elapsed_time += delta
		text.text = format_time(elapsed_time)



func start_timer():
	running = true

func stop_timer():
	running = false

func reset_timer():
	elapsed_time = 0.0

func format_time(seconds: float) -> String:
	var minutes = int(seconds) / 60
	var secs = int(seconds) % 60
	var millis = int((seconds - int(seconds)) * 100)
	
	return "%02d:%02d:%02d" % [minutes, secs, millis]
