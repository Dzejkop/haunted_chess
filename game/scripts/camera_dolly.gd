extends Node3D

@export
var horizontal_rotation_speed: float = 5.0

@export
var idle_horizontal_rotation_speed: float = 2.5

@export
var vertical_rotation_speed: float = 2.0

@export
var translation_speed: float = 10.0

@export
var arm: Node3D

@export	
var camera: Camera3D

@export
var is_active := true

func _process(delta):
	if is_active:
		process_active(delta)
	else:
		process_idle(delta)

func process_active(delta):
	if Input.is_physical_key_pressed(Key.KEY_A):
		rotate(Vector3.UP, delta * horizontal_rotation_speed)
	if Input.is_physical_key_pressed(Key.KEY_D):
		rotate(Vector3.UP, -delta * horizontal_rotation_speed)

	if Input.is_physical_key_pressed(Key.KEY_W):
		camera.translate(Vector3.FORWARD * translation_speed * delta)
	if Input.is_physical_key_pressed(Key.KEY_S):
		camera.translate(-Vector3.FORWARD * translation_speed * delta)

	if Input.is_physical_key_pressed(Key.KEY_R):
		arm.rotate(-Vector3.RIGHT, vertical_rotation_speed * delta)
	if Input.is_physical_key_pressed(Key.KEY_F):
		arm.rotate(Vector3.RIGHT, vertical_rotation_speed * delta)
		
func process_idle(delta):
	rotate(Vector3.UP, delta * idle_horizontal_rotation_speed)
