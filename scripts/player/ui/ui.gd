extends CanvasLayer
class_name UserInterface



@export_category("References")
@export var timer_ui: TimerUI


func _ready() -> void:
	Global.ui = self
