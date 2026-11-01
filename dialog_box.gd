class_name DialogBox
extends PanelContainer

# Bottom-of-screen dialog box, shared by cutscenes.
#     await dialog_box.say("Hello.", "Unknown Voice")
# Types the line out, then waits for Enter or left
# click. A press while typing shows the whole line.
# An empty speaker hides the name.

signal line_dismissed

@export var chars_per_second: float = 40.0

@onready var speaker_label: Label = %Speaker
@onready var text_label: Label = %Text
@onready var hint_label: Label = %Hint

var _typing: bool = false
var _waiting: bool = false
var _tween: Tween


func _ready() -> void:
	hide()
	hint_label.hide()
	# Gentle pulse on the "continue" hint
	var pulse: Tween = create_tween().set_loops()
	pulse.tween_property(hint_label, "modulate:a", 0.3, 0.5)
	pulse.tween_property(hint_label, "modulate:a", 1.0, 0.5)


# Show one line; returns when the player dismisses it
func say(text: String, speaker: String = "") -> void:
	speaker_label.text = speaker
	speaker_label.visible = not speaker.is_empty()
	text_label.text = text
	text_label.visible_ratio = 0.0
	hint_label.hide()
	show()
	_typing = true
	_waiting = false
	var duration: float = maxf(text.length() / chars_per_second, 0.05)
	_tween = create_tween()
	_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_tween.tween_callback(_finish_typing)
	await line_dismissed


func _unhandled_input(event: InputEvent) -> void:
	if not (_typing or _waiting) or not _is_advance(event):
		return
	get_viewport().set_input_as_handled()
	if _typing:
		_finish_typing()
	else:
		_waiting = false
		line_dismissed.emit()


func _finish_typing() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	text_label.visible_ratio = 1.0
	_typing = false
	_waiting = true
	hint_label.show()


func _is_advance(event: InputEvent) -> bool:
	var key: InputEventKey = event as InputEventKey
	if key != null:
		return key.pressed and not key.echo and (key.keycode == KEY_ENTER or key.keycode == KEY_KP_ENTER)
	var mouse: InputEventMouseButton = event as InputEventMouseButton
	return mouse != null and mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT
