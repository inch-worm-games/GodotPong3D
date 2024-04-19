extends RigidBody3D

# Default speed for the paddle
var speed: float = 10.0

# Timestamp of the last hit for use in effects and logic
var last_hit_time = 0.0  # For shader effect timing

func _ready():
	# Lock movement and rotation on certain axes to restrict paddle motion
	axis_lock_linear_x = true
	axis_lock_linear_z = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	# Confirmation of paddle initialization
	print("Paddle initialized.")
	
	# Setup a pulse timer to handle time-based events
	var pulse_timer = $PulseTimer
	pulse_timer.connect("timeout", Callable(self, "_on_pulse_timer_timeout"))

func _physics_process(delta):
	# Initialize the input vector for motion direction
	var input_vector = Vector3.ZERO

	# Adjust the input vector based on player input
	if Input.is_action_pressed("ui_up"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y -= 1

	# Normalize the input vector to maintain consistent movement speed
	input_vector = input_vector.normalized()

	# Apply movement if there is an input
	if input_vector != Vector3.ZERO:
		var movement = input_vector * speed
		linear_velocity = Vector3(0, movement.y, 0)  # Apply only Y-axis motion
	else:
		linear_velocity = Vector3.ZERO  # Stop moving if no input

func _on_ball_instance_created(ball_instance):
	# Connect the 'ball_hit_paddle' signal from the ball instance to this paddle
	var callable = Callable(self, "_on_ball_hit")
	ball_instance.connect("ball_hit_paddle", callable)
	print("Ball hit paddle signal connected.")

func _on_ball_hit(ball_global_position):
	# Output a message and update the last hit time on ball-paddle collision
	print("Ball hit detected at position: ", ball_global_position)

