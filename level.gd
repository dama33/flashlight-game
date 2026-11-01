class_name Level
extends Node2D

@export var monster_scene: PackedScene
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
const MONSTER_SCENE = preload("res://Monster.tscn")

static var instance:Level

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	instance = self
	spawn_random_monster()
	pass # Replace with function body.

func spawn_monster_at_player_position():
	var map:RID = navigation_region.get_navigation_map()
	var layers:int = navigation_region.navigation_layers
	
	var enemy:Node = monster_scene.instantiate()
	enemy.global_position = Player.instance.global_position
	add_child(enemy)


func spawn_random_monster() -> void:
	var map:RID = navigation_region.get_navigation_map()
	var layers:int = navigation_region.navigation_layers

	# Wait until the region's polygons are in the map
	var tries:int = 0
	while NavigationServer2D.map_get_random_point(
			map, layers, true) == Vector2.ZERO:
		tries += 1
		if tries > 60:
			push_error("Navmesh never became ready")
			return
		await get_tree().physics_frame

	# Pick a point away from the player
	var player_pos:Vector2 = Player.instance.global_position
	var pos:Vector2 = Vector2.ZERO
	for i in 20:
		pos = NavigationServer2D.map_get_random_point(
			map, layers, true)
		if pos.distance_to(player_pos) > 300.0:
			break

	var enemy:Node = monster_scene.instantiate()
	enemy.global_position = pos
	add_child(enemy)
