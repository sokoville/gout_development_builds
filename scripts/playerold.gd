extends CharacterBody3D

@export var mouse_sens = 0.08
@export var speed = DEFAULT_SPEED
@export var sprint_speed_multiplier = 1.5
@export var jump_velocity = DEFAULT_JUMP_VELOCITY
@export var fov = 80.0
@export var fov_sprint_additive = 5.0

var mouse_motion = 0

const DEFAULT_SPEED = 5.0
const DEFAULT_JUMP_VELOCITY = 8.0
const CAMERA_ACCELERATION = 40.0

@onready var PlayerMesh = $Mesh
@onready var Head = $Head
@onready var Camera = $Head/Camera

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func handle_mouse_motion(event):
	rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
	Head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
	Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	return -event.relative.x

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	PlayerMesh.visible = false
		
func _input(event):
	#Turns the camera with the mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = handle_mouse_motion(event)
		
func _process(delta):
	# Camera physics interpolation black magic to reduce physics jitter on high refresh-rate monitors
	if Engine.get_frames_per_second() > Engine.physics_ticks_per_second:
		Camera.set_as_top_level(true)
		Camera.global_transform.origin = Camera.global_transform.origin.lerp(Head.global_transform.origin, CAMERA_ACCELERATION * delta)
		Camera.rotation.y = rotation.y
		Camera.rotation.x = Head.rotation.x
	else:
		Camera.set_as_top_level(false)
		Camera.global_transform = Head.global_transform
		
	# Quake style camera tilt with movement 
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	Camera.rotation.z = lerp(Camera.rotation.z, ((-input_dir.x / 30) + (mouse_motion / (DisplayServer.window_get_size().x * .8))), delta * 20) 
	
	# Interactions
#	if RayCast.is_colliding():
#		mInteractions.handle_raycast_collide(RayCast.get_collider())
#	else:
#		mInteractions.clear_interaction_mode()
			
func _physics_process(delta):
	# Adds gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jumping
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Directional movement stuff
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if move_dir:
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed
		Camera.fov = lerp(Camera.fov, fov, delta * 10)
	else:
		velocity.x = 0
		velocity.z = 0
		Camera.fov = lerp(Camera.fov, fov, delta * 10)
		
	move_and_slide()
