class_name Player
extends CharacterBody2D

const SPEED:int = 15000
var speed_scalar = 1.0
static var instance:Player
@onready var SlowTimer:Timer = %SlowTimer

var state:PlayerState = PlayerState.IDLE

enum PlayerState {
	WALKING,
	IDLE,
	GRABBING
}

const max_health = 5
var current_health = 5

func _ready():
	instance = self
	pass;

func _process(delta: float) -> void:	
	look_at(get_global_mouse_position())
	
func _physics_process(delta: float) -> void:
	velocity = Input.get_vector("left","right","up","down").normalized() * delta * SPEED * speed_scalar
	if Input.is_action_just_pressed("spacebar"):
		print("in here")
		%AnimatedSprite2D.play("grab")
		state = PlayerState.GRABBING
		
	if velocity.length() != 0 && state != PlayerState.GRABBING:
		state = PlayerState.WALKING
		%AnimatedSprite2D.play("walk")
		move_and_slide()
	else:
		%AnimatedSprite2D.stop()
	
func _on_collision_polygon_2d_draw() -> void:
	pass

func _on_slow_timer_timeout() -> void:
	speed_scalar = 1.0

func take_damage(damage:int):
	current_health-=damage
	print("Took damage")
	if current_health <= 0:
		print("Died!")
		pass #die


func _on_animated_sprite_2d_animation_finished() -> void:
	print("state over")
	state = PlayerState.IDLE
