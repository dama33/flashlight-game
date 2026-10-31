extends CharacterBody2D


const SPEED = 300.0
const DAMAGE = 2
@onready var AttackTimer:Timer = %AttackTimer

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


func _on_area_2d_body_exited(body: Node2D) -> void:
	AttackTimer.stop()
	pass # Replace with function body.


func _on_area_2d_body_entered(body: Node2D) -> void:
	AttackTimer.start()
	pass # Replace with function body.


func _on_attack_timer_timeout() -> void:
	Player.instance.take_damage(2)
	pass # Replace with function body.
