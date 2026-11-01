class_name Checkpoint
extends Node2D

@export var sprite:Texture2D

@export_group("Split effect")
# Lasting tint on a corpse you've split into
@export var split_tint: Color = Color(0.6, 0.1, 0.1)
# Seconds for the blood to travel player -> body
@export var particle_travel_time: float = 0.45
@export var tint_time: float = 0.5
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
	%SplitSound.play_clip()
	_play_split_fx()
	already_found = true

# Dark red particles flow from the player into the
# body, then the body takes on a red tint
func _play_split_fx() -> void:
	var particles: CPUParticles2D = %SplitParticles
	var from: Vector2 = Player.instance.global_position
	var to_body: Vector2 = global_position - from
	particles.global_position = from
	# Aim in world space, even if the corpse is rotated
	particles.global_rotation = 0.0
	particles.direction = to_body.normalized()
	# Speed so they arrive just as they fade out
	var speed: float = to_body.length() / particle_travel_time
	particles.initial_velocity_min = speed * 0.9
	particles.initial_velocity_max = speed * 1.1
	particles.lifetime = particle_travel_time
	particles.restart()

	var tween: Tween = create_tween()
	tween.tween_interval(particle_travel_time * 0.6)
	tween.tween_property(%Sprite, "modulate", split_tint, tint_time)

func respawn():
	Level.instance.spawn_monster_at_player_position()
	Player.instance.global_position = global_position
	queue_free()


func _on_area_2d_body_exited(body: Node2D) -> void:
	Player.instance.current_checkpoint = null
	%Prompt.visible = false
