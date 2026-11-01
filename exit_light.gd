extends Node2D

# Fake exit: red cone until the player has every
# keycard, then green. In range + open, E asks to
# confirm leaving. The game pauses while asking.

# Not sure if this is needed
signal player_exited

@export var required_cards: int = 5
@export var locked_color: Color = Color(1.0, 0.15, 0.1)
@export var open_color: Color = Color(0.2, 1.0, 0.35)

@onready var light: PointLight2D = %Light
@onready var prompt: Label = %Prompt
@onready var locked_prompt: Label = %LockedPrompt
@onready var confirm_popup: Control = %ConfirmPopup
@onready var yes_button: Button = %YesButton
@onready var no_button: Button = %NoButton

var is_open: bool = false
var has_exited: bool = false
var _player_in_range: bool = false


func _ready() -> void:
	_set_color(locked_color)
	prompt.hide()
	locked_prompt.hide()
	confirm_popup.hide()
	yes_button.pressed.connect(_on_yes_pressed)
	no_button.pressed.connect(_close_popup)


func _process(_delta: float) -> void:
	if is_open:
		return
	var player: Player = Player.instance
	if player != null and player.keycards >= required_cards:
		is_open = true
		_set_color(open_color)
		_update_prompts()


func _unhandled_input(event: InputEvent) -> void:
	if has_exited:
		return
	if confirm_popup.visible:
		if event.is_action_pressed("ui_cancel"):
			_close_popup()
			get_viewport().set_input_as_handled()
		return
	if _player_in_range and is_open and event.is_action_pressed("interact"):
		_open_popup()
		get_viewport().set_input_as_handled()


func _open_popup() -> void:
	confirm_popup.show()
	_update_prompts()
	get_tree().paused = true


func _close_popup() -> void:
	confirm_popup.hide()
	get_tree().paused = false
	_update_prompts()


func _on_yes_pressed() -> void:
	has_exited = true
	confirm_popup.hide()
	get_tree().paused = false
	_update_prompts()
	print("Player stepped out of the dark!")
	# TODO: win screen
	player_exited.emit()


func _update_prompts() -> void:
	var can_show: bool = _player_in_range and not has_exited and not confirm_popup.visible
	prompt.visible = can_show and is_open
	locked_prompt.visible = can_show and not is_open


func _set_color(c: Color) -> void:
	light.color = c


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Player:
		_player_in_range = true
		_update_prompts()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Player:
		_player_in_range = false
		_update_prompts()
