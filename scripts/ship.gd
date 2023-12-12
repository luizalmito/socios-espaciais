extends CharacterBody3D

# Constants
const ACCEL = 1.0
const SPEED = 2.0
const ROT_SPEED_y = 1.5
const ROT_SPEED_x = 1.5
const ROT_SMOOTHNESS = 1.8

# Variables
var rot_velocity: Vector2
var shoot_cd = false

@onready var cannonR = $Spaceship/right_shoot
@onready var cannonL = $Spaceship/left_shoot
@onready var cannon = cannonR

# Signals
signal shoot(position, rotation)

func _process(delta):
	rotate_player(delta)
	shooting() 

func _physics_process(delta):
	move_player(delta)

func rotate_player(delta):
	# Input Handling
	var input_rot = Input.get_vector("tilt_right","tilt_left","tilt_forward","tilt_backward")
	rot_velocity = rot_velocity.move_toward(input_rot, ROT_SMOOTHNESS * delta)
	
	# Rotation
	rotate(transform.basis.x.normalized(), ROT_SPEED_y * rot_velocity.y * delta)
	rotate(transform.basis.y.normalized(), ROT_SPEED_x * rot_velocity.x * delta)
	
	# Animation
	var tween = create_tween().set_parallel()
	tween.tween_property($Spaceship,"rotation", Vector3(0,0,deg_to_rad(35)) * input_rot.x, 1).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property($Camera3D,"position", Vector3(-0.315*input_rot.x,0.2,0.47),2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)

func move_player(delta):
	# Input Handling
	var input_dir = Input.get_axis("move_backward","move_forward")
	
	# Accelerantion
	if (input_dir == 0):
		velocity = velocity.move_toward(Vector3.ZERO, ACCEL* delta)
	elif (input_dir < 0):
		velocity = velocity.move_toward(-transform.basis.z * SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(Vector3.ZERO, SPEED * delta)
	
	# Rotating Velocity Vector
	velocity = velocity.rotated(transform.basis.x.normalized(), ROT_SPEED_y * rot_velocity.y * delta)
	velocity = velocity.rotated(transform.basis.y.normalized(), ROT_SPEED_x * rot_velocity.x * delta)
	
	# Adding velocity
	move_and_collide(velocity * delta)

func shooting():
	if (Input.is_action_pressed("shoot") and shoot_cd == false):
		shoot.emit(cannon.global_position, rotation)
		shoot_cd = true
		await get_tree().create_timer(0.2).timeout
		shoot_cd = false
		if (cannon == cannonR):
			cannon = cannonL
		else:
			cannon = cannonR
