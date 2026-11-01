class_name Player
extends CharacterBody2D

# Signal when playe takes damage
signal damaged(amount: int)

const SPEED:int = 15000
var speed_scalar:float = 1.0
static var instance:Player
@onready var SlowTimer:Timer = %SlowTimer

var checkpoints:Array[Checkpoint]
var current_checkpoint: Checkpoint

var state:PlayerState = PlayerState.IDLE

enum PlayerState {
	WALKING,
	IDLE,
	GRABBING,
	DEAD,
	FALLING
}

const max_health = 5
var current_health = 5
var keycards: int = 0

func _ready():
	instance = self
	pass;

func _process(delta: float) -> void:	
	if state != PlayerState.DEAD && state != PlayerState.FALLING:
		look_at(get_global_mouse_position())
		if Input.is_action_just_pressed("interact") and current_checkpoint != null and !current_checkpoint.already_found:
			checkpoints.append(current_checkpoint)
			current_checkpoint.interact()
	elif state == PlayerState.FALLING:
		scale = lerp(scale, Vector2(0,0),.03)
	
func _physics_process(delta: float) -> void:
	if state != PlayerState.DEAD && state != PlayerState.FALLING:
		velocity = Input.get_vector("left","right","up","down").normalized() * delta * SPEED * speed_scalar
		if Input.is_action_just_pressed("spacebar"):
			print("in here")
			%AnimatedSprite2D.play("grab")
			state = PlayerState.GRABBING
			
		if velocity.length() != 0 && state != PlayerState.GRABBING:
			state = PlayerState.WALKING
			%AnimatedSprite2D.play("walk")
			move_and_slide()
		elif state!= PlayerState.GRABBING:
			%AnimatedSprite2D.stop()
	
func _on_collision_polygon_2d_draw() -> void:
	pass

func _on_slow_timer_timeout() -> void:
	speed_scalar = 1.0

func take_damage(damage:int):
	if state != PlayerState.DEAD:
		current_health-=damage
		damaged.emit(damage)
		print("Took damage")
		if current_health <= 0:
			state = PlayerState.DEAD
			if checkpoints.size() > 0:		
				print("Died!")
				explode()
				%RespawnTimer.start()
			else:
				print("super dead")
				pass

func _on_animated_sprite_2d_animation_finished() -> void:
	print("state over")
	state = PlayerState.IDLE


func _on_respawn_timer_timeout() -> void:
	current_health = max_health
	checkpoints.pop_back().respawn()
	%FallingSprite.visible = false
	%ExplodingSprite.visible = false
	scale = Vector2(.8,.8)
	%AnimatedSprite2D.visible = true
	state = PlayerState.IDLE


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Monster:
		body.is_in_light = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Monster:
		body.is_in_light = false
	pass # Replace with function body.

func fall_in_pit():
	state = PlayerState.FALLING
	
	%ExplodingSprite.visible = false
	%FallingSprite.visible = true
	%AnimatedSprite2D.visible = false
	
func explode():
	%ExplodingSprite.visible = true
	%AnimatedSprite2D.visible = false
