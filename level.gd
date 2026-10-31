extends Node2D

@export var monster_scene: PackedScene
@onready var navigation_region: NavigationRegion2D = $NavigationRegion2D
const MONSTER_SCENE = preload("res://Monster.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#spawn_monster()
	pass # Replace with function body.
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func spawn_random_monster() -> void:
	# Get the navigation map RID
	var map_rid: RID = navigation_region.get_navigation_map()
	
	# Check if the map is valid
	if map_rid.is_valid():
		# Get a random point on the navigation map
		# Parameters: map_rid, navigation_layers (e.g. 1), uniformly (true/false)
		var random_position: Vector2 = NavigationServer2D.map_get_random_point(map_rid, 1, false)
		
		# Instantiate the enemy
		var enemy = monster_scene.instantiate()
		enemy.global_position = random_position
		add_child(enemy)
		
		# Position the enemy on the navmesh point
