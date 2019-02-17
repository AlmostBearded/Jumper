extends KinematicBody2D

export (float) var groundSpeed = 75
export (float) var groundAccel = 600
export (float) var groundDecel = 300
export (float) var airAccel = 100
export (float) var airDecel = 30
export (float) var jumpSpeed = 125
export (float) var gravity = 300
export (float) var cutJumpSpeed = 50
export (float) var reactivityPercent = 1


var velocity = Vector2()
var jumping = false
var synced = false

func _ready():
	set("collision/safe_margin", 0.01)

func _physics_process(delta):
#	print("g: %s, pos: %s, vel: %s, gvel: %s" % 
#			[is_on_floor(), global_position, velocity, get_floor_velocity()])
#	print("g: %s" % 
#			[is_on_floor()])
	
	var input = 0
	if (Input.is_action_pressed("move_right")): input = 1
	if (Input.is_action_pressed("move_left")): input = -1
	
	var has_input = input != 0
	
	if (is_on_floor()):
		# Grounded
		jumping = false
		var moving = velocity.x != 0
		
		var targetSpeed = input * groundSpeed
		if (input != 0 && (sign(velocity.x) == sign(targetSpeed) || velocity.x == 0) && abs(velocity.x) < abs(targetSpeed)):
			# Accel
			var maxAccelAmount = abs(velocity.x - targetSpeed)
			var accelAmount = groundAccel * delta
			velocity.x += input * min(maxAccelAmount, accelAmount)
		else:
			# Decel
			var maxDecelAmount = abs(targetSpeed - velocity.x)
			var decelAmount = groundDecel * delta
			velocity.x -= sign(velocity.x) * min(maxDecelAmount, decelAmount)
		
#		if velocity.x == 0:
##			if get_slide_count() > 0 && synced == false:
##				var c = get_slide_collision(0)
#			if synced == false:
##				global_position.x = ground.global_position.x
#				global_position.x = floor(global_position.x) + (ground.global_position.x - floor(ground.global_position.x))
#				print("%f %f" % [ground.global_position.x, global_position.x])
#				synced = true
#		else:
#			synced = false
		
	else:
		# Airborne
		if (has_input):
			var oppositionPercent = 0 if sign(input) == sign(velocity.x) else 1
			velocity.x += input * (airAccel + airAccel * oppositionPercent * reactivityPercent) * delta 
		else: 
			velocity.x -= sign(velocity.x) * min(abs(velocity.x), airDecel * delta)
		velocity.y += delta * gravity
	
	
	if (Input.is_action_just_pressed("jump")):
		$EarlyJumpToleranceTimer.start()
	
	if (is_on_floor() || !$LateJumpToleranceTimer.is_stopped()):
		if (!$EarlyJumpToleranceTimer.is_stopped()):
			velocity += get_floor_velocity()
			velocity.y -= jumpSpeed
			jumping = true
			$EarlyJumpToleranceTimer.stop()
			$LateJumpToleranceTimer.stop()
	
	if (jumping && !Input.is_action_pressed("jump") && velocity.y < -cutJumpSpeed):
		velocity.y = -cutJumpSpeed
		jumping = false
	
	if jumping || !is_on_floor():
		velocity = move_and_slide(velocity, Vector2(0, -1))
	else:
		velocity = move_and_slide_with_snap(velocity, Vector2(0, 4), Vector2(0, -1))