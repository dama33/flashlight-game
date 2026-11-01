class_name Monster
extends CharacterBody2D

const WALL_MASK:int = 1
const SPEED:float = 100.0
const DAMAGE:int = 2
const AGGRO_RANGE:float = 500.0
var speed_scalar:float = 1.0
var is_in_light:bool = false
@onready var AttackTimer:Timer = %AttackTimer
# Max distance the guess can be off by
@export var max_error:float = 64.0
# Error when right next to the player
@export var min_error:float = 4.0
# At this distance or farther, error is max
@export var error_falloff:float = 300.0
# Seconds between new guesses
@export var repath_interval:float = 0.8
@onready var navi_agent: NavigationAgent2D = $NavigationAgent2D
@onready var occulder: LightOccluder2D = $LightOccluder2D
var _repath_timer:float = 0.0

func _physics_process(delta: float) -> void:
	_repath_timer -= delta
	if _repath_timer <= 0.0:
		# Jitter the timing too, so it isn't
		# perfectly regular
		_repath_timer = repath_interval * randf_range(0.8, 1.2)
		_pick_target()
	if navi_agent.is_navigation_finished():
		velocity = Vector2.ZERO
	else:
		speed_scalar = 0.8 if _is_lit() else 1.0
		var next := navi_agent.get_next_path_position()
		velocity = global_position.direction_to(next) * SPEED * speed_scalar

	if velocity.length() != 0:
		%AnimatedSprite2D.play("default")
	move_and_slide()
	
	%LightRotator.rotation_degrees = rad_to_deg(get_angle_to(Player.instance.global_position))-180

func _pick_target() -> void:
	var player := Player.instance
	if player == null:
		return
	var our_pos = self.position
	if our_pos.distance_to(player.position) > AGGRO_RANGE:
		return
	# Sloppy when far, accurate when close
	var dist:float = global_position.distance_to(player.global_position)
	var t:float = clampf(dist / error_falloff, 0.0, 1.0)
	var err:float = lerpf(min_error, max_error, t)

	# Random point in a circle around the player
	var offset:Vector2 = Vector2.from_angle(randf() * TAU) * randf() * err
	var guess:Vector2 = player.global_position + offset

	# Snap the guess onto the navmesh so it
	# never targets a point inside a wall
	var map := navi_agent.get_navigation_map()
	navi_agent.target_position = NavigationServer2D.map_get_closest_point(map, guess)
func _is_lit() -> bool:
	if not is_in_light:
		return false
	# In the cone; is a wall in the way?
	var player:Player = Player.instance
	var query:PhysicsRayQueryParameters2D = PhysicsRayQueryParameters2D.create(player.global_position,
			global_position, WALL_MASK)
	query.exclude = [player.get_rid()]
	var hit:Dictionary = get_world_2d().direct_space_state.intersect_ray(query)
	return hit.is_empty() or hit.collider == self
	
func _on_area_2d_body_exited(body: Node2D) -> void:
	AttackTimer.stop()
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	AttackTimer.start()
	pass # Replace with function body.


func _on_attack_timer_timeout() -> void:
	Player.instance.take_damage(DAMAGE)
	pass # Replace with function body.
