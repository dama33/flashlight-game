class_name Checkpoint
extends Node2D

@export var sprite:Texture2D
@export var note_title: String = "Note title"
@export_multiline var note_text: String = \
		"(Write this corpse's note in the Inspector.)"
# Screen pixel offset of the menu from the corpse
@export var menu_offset: Vector2 = Vector2(48.0, 0.0)

@onready var Prompt:Label = %Prompt
@onready var Menu: Control = %Menu
@onready var SplitButton: Button = %SplitButton
@onready var NoteButton: Button = %NoteButton
@onready var NoteWindow: Control = %NoteWindow
@onready var NoteTitle: Label = %NoteTitle
@onready var NoteBody: Label = %NoteBody

var already_found: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Sprite.texture = sprite
	NoteTitle.text = note_title
	NoteBody.text = note_text
	NoteButton.disabled = note_text.is_empty()
	SplitButton.pressed.connect(_on_split_pressed)
	NoteButton.pressed.connect(_on_note_pressed)
	# Don't use Player here: in map.tscn the
	# Player is readied after the checkpoint.
	Menu.hide()
	NoteWindow.hide()

func _process(_delta: float) -> void:
	if Menu.visible:
		_place_menu()

# E is read by Player, which calls interact().
# Here we only handle 1 / 2 / Esc while open.
func _unhandled_input(event: InputEvent) -> void:
	if not (Menu.visible or NoteWindow.visible):
		return
	if event.is_action_pressed("ui_cancel"):
		_close_all()
		get_viewport().set_input_as_handled()
		return
	var key: InputEventKey = event as InputEventKey
	if Menu.visible and key != null and key.pressed and not key.echo:
		match key.keycode:
			KEY_1:
				_on_split_pressed()
				get_viewport().set_input_as_handled()
			KEY_2:
				_on_note_pressed()
				get_viewport().set_input_as_handled()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != Player.instance:
		return
	print("Checkpoint range!")
	Player.instance.current_checkpoint = self
	# Shown even after saving, so the note
	# can be read again.
	Prompt.visible = true

# Called by Player when E is pressed in range
func interact() -> void:
	if Menu.visible or NoteWindow.visible:
		_close_all()
	else:
		_open_menu()

func respawn():
	var player: Player = Player.instance
	if player.current_checkpoint == self:
		player.current_checkpoint = null
	player.global_position = global_position
	queue_free()


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body != Player.instance:
		return
	# Overlapping radii: only clear if it's us
	if Player.instance.current_checkpoint == self:
		Player.instance.current_checkpoint = null
	_close_all()

# --- Menu -----------------------------------------

func _open_menu() -> void:
	Prompt.visible = false
	NoteWindow.hide()
	SplitButton.disabled = already_found
	SplitButton.text = "Saved" if already_found else "1  Split"
	_place_menu()
	Menu.show()

func _close_all() -> void:
	Menu.hide()
	NoteWindow.hide()
	var player: Player = Player.instance
	Prompt.visible = player != null and player.current_checkpoint == self

# Keep the menu beside the corpse on screen
func _place_menu() -> void:
	var screen_pos: Vector2 = get_global_transform_with_canvas().origin
	var pos: Vector2 = screen_pos + menu_offset
	pos.y -= Menu.size.y / 2.0
	var view: Vector2 = get_viewport_rect().size
	pos = pos.clamp(Vector2.ZERO, view - Menu.size)
	Menu.position = pos

func _on_split_pressed() -> void:
	if already_found:
		return
	already_found = true
	Player.instance.checkpoints.append(self)
	_close_all()
	_play_split_effect()

func _on_note_pressed() -> void:
	if note_text.is_empty():
		return
	Menu.hide()
	NoteWindow.show()

# Placeholder until the real split animation
func _play_split_effect() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(%Sprite, "modulate",
			Color(2.0, 2.0, 2.0), 0.1)
	tween.tween_property(%Sprite, "modulate",
			Color.WHITE, 0.3)
