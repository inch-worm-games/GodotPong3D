extends Node

# Preloads the ball scene for later instantiation
var ball_scene = preload("res://scenes/ball.tscn")

# Holds the instance of the currently active ball
var ball_instance = null

# Scores for player 1 and player 2
var player1_score = 0
var player2_score = 0

# Toggle for auto respawning the ball
var auto_respawn = false  # Set to true for automatic respawning

# Reference to the paddle node
var paddle

func _ready():
	# Initialize the paddle; update the path if needed
	paddle = get_node("paddle")

func _process(delta):
	# Handles the ball spawning based on the auto_respawn flag
	if auto_respawn and not ball_instance:
		spawn_ball()
	elif not auto_respawn and Input.is_action_just_pressed("ui_accept"):
		spawn_ball()

func spawn_ball():
	# Free the existing ball instance if it exists
	if ball_instance:
		ball_instance.queue_free()

	# Create a new ball instance and set its position
	ball_instance = ball_scene.instantiate()
	add_child(ball_instance)
	ball_instance.global_transform.origin = Vector3(0, 0, 0)

	# Connects the ball instance to the paddle's signal receiver method
	if paddle:
		var callable = Callable(paddle, "_on_ball_hit")
		ball_instance.connect("ball_hit_paddle", callable)
	else:
		print("Paddle not found.")

func on_p1_score_zone_body_entered(body):
	# Increments player 1's score when the ball enters the scoring zone
	if body == ball_instance:
		player1_score += 1
		print("Player 1 Scored. Score: ", player1_score)
		# Conditionally respawns the ball based on auto_respawn
		if auto_respawn:
			spawn_ball()
		else:
			ball_instance.queue_free()
			ball_instance = null

func on_p2_score_zone_body_entered(body):
	# Increments player 2's score when the ball enters the scoring zone
	if body == ball_instance:
		player2_score += 1
		print("Player 2 Scored. Score: ", player2_score)
		# Conditionally respawns the ball based on auto_respawn
		if auto_respawn:
			spawn_ball()
		else:
			ball_instance.queue_free()
			ball_instance = null
