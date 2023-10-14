extends CharacterBody3D

const Guns_Script = preload("res://scripts/guns.gd")

var mGuns = null

@export var max_speed = DEFAULT_MAX_SPEED
@export var jump_velocity = DEFAULT_JUMP_VELOCITY
@export var movemement_acceleration = DEFAULT_MOVEMENT_ACCELERATION
@export var mouse_sens = 0.05
@export var health = 100
@export var armour = 0
@export var current_speed = 0
@export var equipped_weapons = [["MP5", 30], ["Pistol", 15], ["empty", -1]]
@export var weapons_slot = -1
@export var ammo = {"pistol_ammo" = 50, "smg_ammo" = 70}

@onready var Head : Node3D = $Head
@onready var Camera : Camera3D = $Head/Camera
@onready var GunCam : Camera3D = $Head/Camera/Hand/ViewmodelContainer/ViewmodelPort/GunCam
@onready var CollisionShape : CollisionShape3D = $CollisionShape3D
@onready var HeadCheck : RayCast3D = $Head/HeadCheck
@onready var InteractionCheck : RayCast3D = $Head/Camera/InteractionCheck
@onready var PlayerMesh : MeshInstance3D = $Mesh
@onready var Hand : Node3D = $Head/Camera/Hand

const DEFAULT_JUMP_VELOCITY = 8.0
const DEFAULT_MAX_SPEED = 8.0
const DEFAULT_MOVEMENT_ACCELERATION = 10.0
const CAMERA_ACCELERATION = 80.0
const CAMERA_BOB_FREQ = 2.0
const CAMERA_BOB_AMP = 0.05

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var mouse_motion = 0
var crouched = false
var head_bob_time = 0.0
var frames_on_ground = 0

func calculate_headbob(target):
	if target == "camera":
		var pos = 0
		pos += sin(head_bob_time * CAMERA_BOB_FREQ) * CAMERA_BOB_AMP
		return pos
	elif target == "gun":
		var pos = 0
		pos += sin(head_bob_time * (CAMERA_BOB_FREQ)) * (CAMERA_BOB_AMP/4)
		return pos

func handle_mouse_motion(event):
	rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
	Head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
	Head.rotation.x = clamp(Head.rotation.x, deg_to_rad(-89), deg_to_rad(89))
	return -event.relative.x

func _ready():
	mGuns = Guns_Script.new()
	mGuns._setup(self)
		
func _input(event):
	#Turns the camera with the mouse movement
	if event is InputEventMouseMotion:
		mouse_motion = handle_mouse_motion(event)
		
	if Input.is_action_just_pressed("interact"):
		if InteractionCheck.is_colliding():
			var collider = InteractionCheck.get_collider()
			if collider.has_meta("interactable"):
				collider.call("interact")
				
	if not OS.is_debug_build():
		PlayerMesh.visible = false

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
	
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	Camera.rotation.z = lerp(Camera.rotation.z, ((-input_dir.x / 20) + (mouse_motion / (DisplayServer.window_get_size().x * .8))), delta * 10)
	Hand.rotation.x = lerp(Hand.rotation.x, -((-input_dir.x / 20) + (mouse_motion / (DisplayServer.window_get_size().x * .8))), delta * 10)  
		
	if Input.is_action_just_pressed("primary_fire"):
		mGuns.handle_primary_fire("press")
	if Input.is_action_pressed("primary_fire"):
		mGuns.handle_primary_fire("hold")
		
	if Input.is_action_just_pressed("secondary_fire"):
		mGuns.handle_secondary_fire("press")
	if Input.is_action_pressed("secondary_fire"):
		mGuns.handle_secondary_fire("hold")
		
	if Input.is_action_just_pressed("reload"):
		mGuns.handle_reload()
		
	if Input.is_action_just_pressed("slot1"):
		mGuns.update_gun(0)
	
	if Input.is_action_just_pressed("slot2"):
		mGuns.update_gun(1)
		
	if Input.is_action_just_pressed("slot3"):
		mGuns.update_gun(2)
	
	if Input.is_action_just_released("slot_up"):
		if weapons_slot < equipped_weapons.size() - 1:
			mGuns.update_gun(weapons_slot + 1)
		else:
			mGuns.update_gun(0)
	
	if Input.is_action_just_released("slot_down"):
		if weapons_slot != 0:
			mGuns.update_gun(weapons_slot - 1)
		else:
			mGuns.update_gun(equipped_weapons.size() - 1)
		
	GunCam.global_transform = Camera.global_transform

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity
		max_speed += 1
		frames_on_ground = 0
		
	if Input.is_action_pressed("crouch"):
		CollisionShape.shape.height = 0.9
		Head.position.y = 0.3
		Hand.position.y = -0.2 # BAD HEIGHT 
		crouched = true
	else:
		if not HeadCheck.is_colliding():
			Head.position.y = 0.6
			Hand.position.y = -0.275
			if crouched:
				self.position.y += .5 # HACKY SOLUTION TO GETTING STUCK IN THE GROUND FIX LATER
				CollisionShape.shape.height = 1.8
				crouched = false
		else:
			Head.position.y = 0.3
			
	if Input.is_action_pressed("walk"):
		max_speed = DEFAULT_MAX_SPEED / 2
		
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		frames_on_ground += 1
		if move_dir:
			velocity.x = lerp(velocity.x, move_dir.x * max_speed, movemement_acceleration * delta)
			velocity.z = lerp(velocity.z, move_dir.z * max_speed, movemement_acceleration * delta)
		else:
			velocity.x = 0
			velocity.z = 0
	
		if frames_on_ground * delta > 0.2:
			max_speed = DEFAULT_MAX_SPEED
	else:
		velocity.x = lerp(velocity.x, move_dir.x * max_speed, delta * 4.0)
		velocity.z = lerp(velocity.z, move_dir.z * max_speed, delta * 4.0)
		
	head_bob_time += velocity.length() * float(is_on_floor()) * delta
	Head.position.y = Head.position.y + calculate_headbob("camera")
	Hand.position.y = Hand.position.y + calculate_headbob("gun")
	
	current_speed = velocity.length()
		
	move_and_slide()
