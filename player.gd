extends CharacterBody2D

const SPEED:int = 30000

func _ready():
	pass;
	
func _input(event: InputEvent) -> void:
	pass
	
func _process(delta: float) -> void:
	velocity = Input.get_vector("left","right","up","down") * delta * SPEED
	
func _physics_process(delta: float) -> void:
	move_and_slide()
	
	
