extends CharacterBody3D

## FPSController — First-person movement, collision with voxels, and interaction.

signal player_position_changed(pos: Vector3)

const WALK_SPEED := 5.0
const RUN_SPEED := 9.0
const FLY_SPEED := 12.0
const JUMP_VELOCITY := 6.0
const GRAVITY := 18.0
const MOUSE_SENSITIVITY := 0.002

var is_flying: bool = false
var current_speed: float = 5.0
var _camera: Camera3D = null
var _interaction_ray: RayCast3D = null
var _build_tool: Node = null
var _voxel_engine: Node3D = null


func _ready() -> void:
	_camera = Camera3D.new()
	_camera.position = Vector3(0, 1.6, 0)
	_camera.fov = 75.0
	_camera.rotation.x = -0.3
	add_child(_camera)

	_interaction_ray = RayCast3D.new()
	_interaction_ray.position = Vector3(0, 1.6, 0)
	_interaction_ray.target_position = Vector3(0, 0, -6)
	_interaction_ray.collision_mask = 1 | 4 | 8
	_interaction_ray.enabled = true
	add_child(_interaction_ray)

	var build_tool_script = load("res://scripts/player/build_tool.gd")
	if build_tool_script != null:
		_build_tool = Node.new()
		_build_tool.set_script(build_tool_script)
		add_child(_build_tool)

	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	_voxel_engine = get_node_or_null("/root/Main/World/VoxelEngine")
	if _voxel_engine != null:
		player_position_changed.connect(_on_player_moved)

	position = Vector3(8, 8, 8)

	if _voxel_engine != null and _voxel_engine.has_method("update_player_position"):
		_voxel_engine.update_player_position(global_position)


func _on_player_moved(pos: Vector3) -> void:
	if _voxel_engine != null and _voxel_engine.has_method("update_player_position"):
		_voxel_engine.update_player_position(pos)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		_camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		_camera.rotation.x = clampf(_camera.rotation.x, -PI / 2.0 + 0.01, PI / 2.0 - 0.01)

	if event.is_action_pressed("jump") and Input.is_key_pressed(KEY_CTRL):
		is_flying = not is_flying

	if event.is_action_pressed("ui_cancel"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("toggle_build_menu"):
		if _build_tool != null:
			_build_tool.toggle_menu()

	if event.is_action_pressed("toggle_debug"):
		_toggle_debug_overlay()


func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("sprint"):
		if is_flying:
			current_speed = FLY_SPEED * 1.5
		else:
			current_speed = RUN_SPEED
	else:
		if is_flying:
			current_speed = FLY_SPEED
		else:
			current_speed = WALK_SPEED

	var input_dir := Vector2.ZERO
	if Input.is_action_pressed("move_forward"):
		input_dir.y -= 1
	if Input.is_action_pressed("move_backward"):
		input_dir.y += 1
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1
	input_dir = input_dir.normalized()

	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if is_flying:
		velocity = direction * current_speed
		if Input.is_action_pressed("jump"):
			velocity.y = current_speed
		elif Input.is_key_pressed(KEY_SHIFT):
			velocity.y = -current_speed
	else:
		if not is_on_floor():
			velocity.y -= GRAVITY * delta
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed

	move_and_slide()
	player_position_changed.emit(global_position)

	if Input.is_action_just_pressed("interact"):
		_handle_interact()
	elif Input.is_action_just_pressed("destroy"):
		_handle_destroy()


func _handle_interact() -> void:
	if _build_tool != null and _interaction_ray.is_colliding():
		var hit_point := _interaction_ray.get_collision_point()
		var hit_normal := _interaction_ray.get_collision_normal()
		_build_tool.place_at(hit_point, hit_normal)


func _handle_destroy() -> void:
	if _build_tool != null and _interaction_ray.is_colliding():
		var hit_point := _interaction_ray.get_collision_point()
		var hit_normal := _interaction_ray.get_collision_normal()
		_build_tool.destroy_at(hit_point, hit_normal)


func get_camera() -> Camera3D:
	return _camera


func get_interaction_ray() -> RayCast3D:
	return _interaction_ray


func _toggle_debug_overlay() -> void:
	var hud = get_node_or_null("/root/Main/UI")
	if hud != null and hud.has_method("toggle_debug"):
		hud.toggle_debug()