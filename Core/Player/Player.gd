extends KinematicBody2D

export (float) var ground_speed = 75
export (float) var ground_accel = 600
export (float) var ground_decel = 300
export (float) var air_accel = 50
export (float) var air_decel = 30
export (float) var jump_speed = 100
export (float) var gravity = 300
export (float) var cut_jump_speed = 50
export (float) var reactivity_percent = 2

const CAMERA_OFFSET_DIR = false

var velocity = Vector2()
var jumping = false
var synced = false
var input : float = 0
onready var camera_offset = abs($CameraPivot.position.x)

func _ready():
	set("collision/safe_margin", 0.01)

func _process(delta):
	input = 0
	if Input.is_action_pressed("move_right"): 
		input = 1
	if Input.is_action_pressed("move_left"): 
		input = -1

func _physics_process(delta):
#	print("g: %s, pos: %s, vel: %s, gvel: %s" % 
#			[is_on_floor(), global_position, velocity, get_floor_velocity()])
#	print("g: %s" % 
#			[is_on_floor()])
	
	if (is_on_floor()):
		# Grounded
		jumping = false
		
		var target_speed = input * ground_speed
		if (input != 0 && abs(velocity.x) < abs(target_speed)):
			# Accel
			var opposition_percent = 0 if sign(input) == sign(velocity.x) else 1
			var max_accel_amount = abs(velocity.x - target_speed)
			var accel_amount = (ground_accel + ground_accel * opposition_percent * 
					reactivity_percent) * delta
			velocity.x += input * min(max_accel_amount, accel_amount)
		else:
			# Decel
			var maxDecelAmount = abs(target_speed - velocity.x)
			var decelAmount = ground_decel * delta
			velocity.x -= sign(velocity.x) * min(maxDecelAmount, decelAmount)
		
	else:
		# Airborne
		if (input != 0):
			var opposition_percent = 0 if sign(input) == sign(velocity.x) else 1
			velocity.x += input * (air_accel + air_accel * opposition_percent * reactivity_percent) * delta 
		else: 
			velocity.x -= sign(velocity.x) * min(abs(velocity.x), air_decel * delta)
		velocity.y += delta * gravity
	
	
	
	if (!jumping && (is_on_floor() || !$LateJumpToleranceTimer.is_stopped())):
		if (Input.is_action_pressed("jump")):
			velocity += get_floor_velocity()
			velocity.y -= jump_speed
			jumping = true
			$LateJumpToleranceTimer.stop()
	
	if (jumping && !Input.is_action_pressed("jump") && velocity.y < -cut_jump_speed):
		velocity.y = -cut_jump_speed
		jumping = false
	
	if CAMERA_OFFSET_DIR && velocity.x != 0:
		$CameraPivot.position.x = camera_offset * sign(velocity.x)
	
	if jumping || !is_on_floor():
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 4), Vector2(0, -1))