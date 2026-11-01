class_name Checkpoint
extends Node2D

@export var note_title := "Note title"
@export_multiline var note_text := ""
@onready var Prompt:Label = %Prompt

var already_found: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Checkpoint range!")
	Prompt.set_visible(true);
	if !already_found:
		Player.instance.checkpoints.append(self)
		already_found = true

func respawn():
	Player.instance.global_position = global_position
	queue_free()
