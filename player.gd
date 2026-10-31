class_name Player
extends CharacterBody2D

const SPEED:int = 30000
var speed_scalar = 1.0
static var instance:Player
@onready var SlowTimer:Timer = %SlowTimer

const max_health = 5
var current_health = 5

func _ready():
	instance = self
	pass;
	
func _input(event: InputEvent) -> void:
	pass
	
func _process(delta: float) -> void:	
	velocity = Input.get_vector("left","right","up","down").normalized() * delta * SPEED * speed_scalar
	look_at(get_global_mouse_position())
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	
func _on_collision_polygon_2d_draw() -> void:
	pass

func _on_slow_timer_timeout() -> void:
	speed_scalar = 1.0

func take_damage(damage:int):
	current_health-=damage
	if current_health <= 0:
		pass #die
