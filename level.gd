extends Node2D

const MONSTER_SCENE = preload("res://Monster.tscn")
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	spawn_monster()
	pass # Replace with function body.
@onready var tile_map_layer: TileMapLayer = $TileMapLayer


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func spawn_monster() -> void:
	var new_monster = MONSTER_SCENE.instantiate()
	var user_rect:Rect2i = tile_map_layer.get_used_rect()
	
	new_monster.position = Vector2(10.0, 10.0)
	add_child(new_monster)
	pass
