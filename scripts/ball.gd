extends RigidBody3D

# Initial and maximum speeds settings
@export var initial_speed = 10
@export var max_speed_limit = 50
@export var speed_increase_factor = 1.05
var max_speed = initial_speed  # Maximum dynamic speed, starts at initial_speed

# Signal to notify when the ball hits a paddle
signal ball_hit_paddle

func _ready():
	# Sets a random initial direction (on the X and Y axes) and applies initial speed
	var initial_direction = Vector3(randf_range(-1, 1), randf_range(-1, 1), 0).normalized()
	linear_velocity = initial_direction * initial_speed

	# Constrain movement strictly to the XY plane by locking the Z-axis
	set_axis_lock(PhysicsServer3D.BODY_AXIS_LINEAR_Z, true)

func _on_Ball_body_entered(body):
	# Respond to collisions with walls or paddles
	if body.is_in_group("wall") or body.is_in_group("paddle"):
		# Increase speed following a collision, without exceeding the set maximum
		max_speed = min(max_speed * speed_increase_factor, max_speed_limit)
		linear_velocity = linear_velocity.normalized() * max_speed

		# Add a random spin to the ball upon collision
		var spin_axis = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized()
		var spin_strength = randf_range(1.0, 5.0)
		angular_velocity += spin_axis * spin_strength

	# Special handling for paddle collisions
	if body.is_in_group("paddle"):
		# Emit a signal with the collision point when the ball hits a paddle
		emit_signal("ball_hit_paddle", global_transform.origin)

func _process(delta):
	# Cap the ball's speed to the maximum speed limit
	if linear_velocity.length() > max_speed_limit:
		linear_velocity = linear_velocity.normalized() * max_speed_limit
