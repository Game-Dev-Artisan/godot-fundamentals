extends CharacterBody2D
class_name Tank

# Define the constant values for SPEED and TURN_SPEED
const SPEED = 64.0
const TURN_SPEED = 2

# Setup our direction internal property
var direction: Vector2 = Vector2.RIGHT

func _physics_process(delta):
	# Calculate a vector based on our input actions mapped on 2 axis
	var input_direction := Input.get_vector("turn_left", "turn_right", "move_backward", "move_forward")
	if input_direction.x != 0:
		# Rotate direction based on our input vector and apply turn speed.
		direction = direction.rotated(input_direction.x * (PI / 2) * TURN_SPEED * delta)
		rotation = direction.angle()
	if input_direction.y != 0:
		# Move in a forward/backward motion and play animation
		$AnimationPlayer.play("move")
		velocity = lerp(velocity, (direction.normalized() * input_direction.y) * SPEED, SPEED * delta)
	else:
		# Bring to a stop
		velocity = Vector2.ZERO 
		$AnimationPlayer.play("idle")
	# Apply our movement velocity
	move_and_slide()
