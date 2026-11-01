class_name Player
extends CharacterBody2D

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
	DEAD
}

const max_health = 5
var current_health = 5

func _ready():
	instance = self
	pass;

func _process(delta: float) -> void:	
	look_at(get_global_mouse_position())
	# The checkpoint opens its Split / Note menu;
	# saving now happens on Split, not here.
	if Input.is_action_just_pressed("interact") \
			and is_instance_valid(current_checkpoint) \
			and state != PlayerState.DEAD:
		current_checkpoint.interact()
	
func _physics_process(delta: float) -> void:
	if state != PlayerState.DEAD:
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
		print("Took damage")
		if current_health <= 0:
			state = PlayerState.DEAD
			if checkpoints.size() > 0:		
				print("Died!")
				%RespawnTimer.start()
			else:
				print("super dead")
				pass

func _on_animated_sprite_2d_animation_finished() -> void:
	print("state over")
	# Only the one-shot "grab" anim ends here. Never
	# leave DEAD: that revived the player at <= 0 HP.
	if state == PlayerState.GRABBING:
		state = PlayerState.IDLE


func _on_respawn_timer_timeout() -> void:
	current_health = max_health
	checkpoints.pop_back().respawn()
	state = PlayerState.IDLE


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body is Monster:
		body.is_in_light = true
		
		
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	if body is Monster:
		body.is_in_light = false
	pass # Replace with function body.
