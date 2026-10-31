extends CharacterBody2D


const SPEED = 100.0
const DAMAGE = 2
const AGGRO_RANGE = 500.0
@onready var AttackTimer:Timer = %AttackTimer
# Max distance the guess can be off by
@export var max_error := 64.0
# Error when right next to the player
@export var min_error := 4.0
# At this distance or farther, error is max
@export var error_falloff := 300.0
# Seconds between new guesses
@export var repath_interval := 0.8
@onready var navi_agent: NavigationAgent2D = $NavigationAgent2D
var _repath_timer := 0.0

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
		var next := navi_agent.get_next_path_position()
		velocity = global_position.direction_to(next) * SPEED

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
	var dist := global_position.distance_to(player.global_position)
	var t := clampf(dist / error_falloff, 0.0, 1.0)
	var err := lerpf(min_error, max_error, t)

	# Random point in a circle around the player
	var offset := Vector2.from_angle(randf() * TAU) * randf() * err
	var guess := player.global_position + offset

	# Snap the guess onto the navmesh so it
	# never targets a point inside a wall
	var map := navi_agent.get_navigation_map()
	navi_agent.target_position = NavigationServer2D.map_get_closest_point(map, guess)

func _on_area_2d_body_exited(body: Node2D) -> void:
	AttackTimer.stop()
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	AttackTimer.start()
	pass # Replace with function body.


func _on_attack_timer_timeout() -> void:
	Player.instance.take_damage(2)
	pass # Replace with function body.
