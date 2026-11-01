extends CanvasLayer

# Basic HUD: health and key cards, top left.

const CARD_LIT: Color = Color(1.0, 1.0, 1.0, 1.0)
const CARD_DIM: Color = Color(0.45, 0.45, 0.45, 0.9)

@export var total_cards: int = 5
@export var card_texture: Texture2D
@export var card_icon_size: Vector2 = Vector2(64.0, 64.0)
# Same tilt as the Keycard sprite in the world
@export var card_icon_angle: float = -45.0

@onready var health_label: Label = %HealthLabel
@onready var card_row: HBoxContainer = %CardRow

var _card_icons: Array[TextureRect] = []


func _ready() -> void:
	# One dimmed icon per card
	for i: int in total_cards:
		var icon: TextureRect = TextureRect.new()
		icon.texture = card_texture
		icon.custom_minimum_size = card_icon_size
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		icon.modulate = CARD_DIM
		# Rotate around the icon centre, not its corner
		icon.pivot_offset = card_icon_size / 2.0
		icon.rotation_degrees = card_icon_angle
		card_row.add_child(icon)
		_card_icons.append(icon)


func _process(_delta: float) -> void:
	var player: Player = Player.instance
	if player == null:
		return
	var hp: int = maxi(player.current_health, 0)
	health_label.text = "HP: %d / %d" % [hp, player.max_health]
	# Light up cards from left to right always
	for i: int in _card_icons.size():
		var lit: bool = i < player.keycards
		_card_icons[i].modulate = CARD_LIT if lit else CARD_DIM
