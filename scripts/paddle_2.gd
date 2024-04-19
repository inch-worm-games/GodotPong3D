extends RigidBody3D

# Configuration variables for AI paddle behavior
var max_speed: float = 10.0  # Maximum speed of the AI paddle
var acceleration: float = 50.0  # Acceleration rate of the AI paddle
var reaction_delay: float = 0.1  # Delay in seconds before AI reacts
var target_zone_radius: float = 1.0  # Radius of the target zone around the ball's position
var imperfection_chance: float = 0.25  # Chance for AI to not move optimally
var delay_timer: float = 0.0  # Timer to track reaction delay
var prediction_time: float = 0.5  # Time ahead to predict the ball's position
var game_manager: Node  # Reference to the game manager

func _ready():
	# Locking the axes to prevent unwanted movement and rotation
	axis_lock_linear_x = true
	axis_lock_linear_z = true
	axis_lock_angular_x = true
	axis_lock_angular_y = true
	axis_lock_angular_z = true

	# Getting the parent node which is assumed to be the game manager
	game_manager = get_parent()

func _physics_process(delta):
	# Ensuring that there is a ball instance to interact with
	if not game_manager.ball_instance:
		linear_velocity = Vector3.ZERO  # Stop moving if there's no ball
		return

	# Update the reaction delay timer
	delay_timer += delta

	# Check if the delay timer has completed to start reacting
	if delay_timer < reaction_delay:
		return  # Waiting for the reaction delay to pass

	# Predicting the ball's future position
	var ball = game_manager.ball_instance
	var future_position = ball.global_transform.origin + ball.linear_velocity * prediction_time

	# Calculate the target position taking into account a random 'imperfection' factor
	var target_position_y = future_position.y + randf_range(-target_zone_radius, target_zone_radius) * (1.0 - imperfection_chance)

	# Determine the distance to the target position
	var distance_to_target = target_position_y - global_transform.origin.y

	# Decide the target velocity based on the distance to target
	var target_velocity = Vector3.ZERO
	if abs(distance_to_target) > target_zone_radius:
		if distance_to_target > 0:
			target_velocity = Vector3(0, max_speed, 0)  # Move up
		else:
			target_velocity = Vector3(0, -max_speed, 0)  # Move down
	else:
		delay_timer = 0  # Reset delay timer when in target zone

	# Apply a smooth transition to the new target velocity
	linear_velocity = linear_velocity.lerp(target_velocity, acceleration * delta)
