extends Node2D

@export var noise_radius:float = 0.0
@export var spread:float = 35.0 # so monsters don't try stacking on top of each other
var triggered:bool = false


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _alert_monsters() -> void:
	# Finds placed AND spawned monsters.
	# owned=false: spawned ones have no owner.
	var root: Node = get_tree().current_scene
	var characters: Array[Node] = root.find_children("*", "CharacterBody2D", true, false)
	for node: Node in characters:
		var monster: Monster = node as Monster
		if monster == null:
			continue
		var dist: float = monster.global_position.distance_to(global_position)
		if noise_radius > 0.0 and dist > noise_radius:
			continue
		_send_noise_pos(monster)
func _send_noise_pos(monster: Monster) -> void:
	var agent: NavigationAgent2D = monster.navi_agent
	var offset: Vector2 = Vector2.from_angle(randf() * TAU) * randf() * spread
	var map: RID = agent.get_navigation_map()
	var spot: Vector2 = global_position + offset
	agent.target_position = NavigationServer2D.map_get_closest_point(map, spot)
	
func _on_area_2d_body_entered(body: Node2D) -> void:
	if triggered or not (body is Player):
		return
	triggered = true
	$Area2D.set_deferred("monitoring", false)
	print("Sound trap triggered!")
	_alert_monsters()
	queue_free()
	# Have monsters converge to the sound trap location
	pass # Replace with function body.
