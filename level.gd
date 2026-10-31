extends Node2D

@export var monster_scene: PackedScene
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
const MONSTER_SCENE = preload("res://Monster.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	spawn_random_monster()
	pass
func spawn_random_monster() -> void:
	var map := navigation_region.get_navigation_map()
	var layers := navigation_region.navigation_layers

	# Wait until the region's polygons are in the map
	var tries := 0
	while NavigationServer2D.map_get_random_point(
			map, layers, true) == Vector2.ZERO:
		tries += 1
		if tries > 60:
			push_error("Navmesh never became ready")
			return
		await get_tree().physics_frame

	# Pick a point away from the player
	var player_pos := Player.instance.global_position
	var pos := Vector2.ZERO
	for i in 20:
		pos = NavigationServer2D.map_get_random_point(
			map, layers, true)
		if pos.distance_to(player_pos) > 150.0:
			break

	var enemy := monster_scene.instantiate()
	enemy.global_position = pos
	add_child(enemy)
