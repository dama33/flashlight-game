extends Node

# Flash red a few times when player takes damage

@export var target: CanvasItem
@export var flash_color: Color = Color(1.0, 0.25, 0.25, 0.5)
@export var flashes: int = 3

@export var flash_time: float = 0.08

var _tween: Tween


func _ready() -> void:
	var player: Player = get_parent() as Player
	player.damaged.connect(_on_player_damaged)
	# Not assigned in the Inspector: use the
	# player's walking sprite
	if target == null:
		target = player.get_node_or_null("AnimatedSprite2D") as CanvasItem


func _on_player_damaged(_amount: int) -> void:
	flash()


func flash() -> void:
	# A new hit restarts the flicker
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = create_tween().set_loops(flashes)
	_tween.tween_callback(_set_tint.bind(flash_color))
	_tween.tween_interval(flash_time)
	_tween.tween_callback(_set_tint.bind(Color.WHITE))
	_tween.tween_interval(flash_time)


func _set_tint(c: Color) -> void:
	if target != null:
		target.modulate = c
