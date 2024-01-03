extends CharacterBody3D

# Constants
const ACCEL = 1.0
const SPEED = 2.0
const ROT_SPEED_y = 1.5
const ROT_SPEED_x = 1.5
const ROT_SMOOTHNESS = 1.8

# Variables
var rot_velocity: Vector2

func _ready():
	if multiplayer.get_unique_id() != 1:
		set_script(null)
		return
	$subCam.make_current()

func _process(delta):
	rotate_player(delta)

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
	tween.tween_property($submarine,"rotation:x", -deg_to_rad(35) * input_rot.x, 1)
	tween.tween_property($subCam,"position", Vector3(-0.315*input_rot.x,0.2,0.47),2)

func move_player(delta):
	# Input Handling
	var input_dir = Input.get_axis("move_backward","move_forward")
	
	# Accelerantion
	if (input_dir == 0):
		velocity = velocity.move_toward(Vector3.ZERO, ACCEL* delta)
		pass
	elif (input_dir < 0):
		velocity = velocity.move_toward(-transform.basis.z * SPEED, ACCEL * delta)
	else:
		velocity = velocity.move_toward(transform.basis.z * SPEED, ACCEL * delta)
	
	# Rotating Velocity Vector
	velocity = velocity.rotated(transform.basis.x.normalized(), ROT_SPEED_y * rot_velocity.y * delta)
	velocity = velocity.rotated(transform.basis.y.normalized(), ROT_SPEED_x * rot_velocity.x * delta)
	
	# Adding velocity
	move_and_collide(velocity * delta)
