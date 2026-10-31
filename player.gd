class_name Player
extends CharacterBody2D

const SPEED:int = 30000
var speed_scalar = 1.0
static var MainPlayer:Player
@onready var SlowTimer:Timer = %SlowTimer


func _ready():
	MainPlayer = self
	pass;
	
func _input(event: InputEvent) -> void:
	pass
	
func _process(delta: float) -> void:
		
	velocity = Input.get_vector("left","right","up","down") * delta * SPEED * speed_scalar
	look_at(get_global_mouse_position())
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	
	


func _on_collision_polygon_2d_draw() -> void:
	pass


func _on_slow_timer_timeout() -> void:
	speed_scalar = 1.0
