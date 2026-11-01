class_name Checkpoint
extends Node2D

@export var sprite:Texture2D
@onready var Prompt:Label = %Prompt

var already_found: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	%Sprite.texture = sprite
	pass # Replace with function body.

func _on_area_2d_body_entered(body: Node2D) -> void:
	print("Checkpoint range!")
	if !already_found:
		%Prompt.visible = true
		Player.instance.current_checkpoint = self

func interact():
	%Prompt.visible = false
	already_found = true

func respawn():
	Player.instance.global_position = global_position
	queue_free()


func _on_area_2d_body_exited(body: Node2D) -> void:
	Player.instance.current_checkpoint = null
	%Prompt.visible = false
