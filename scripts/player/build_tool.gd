extends Node

## BuildTool — Handles voxel placement, destruction, and prefab stamping.
## Manages the build menu UI state and ghost preview.

signal build_mode_changed(mode: String)
signal selected_block_changed(type: int)
signal selected_prefab_changed(prefab_name: String)

enum Mode { NONE, VOXEL, PREFAB }

var current_mode: int = 0
var selected_voxel_type: int = 3
var selected_prefab_name: String = ""
var _ghost_mesh: MeshInstance3D = null
var _menu_visible: bool = false
var _voxel_engine: Node3D = null


func _ready() -> void:
	_ghost_mesh = MeshInstance3D.new()
	var ghost_mat := StandardMaterial3D.new()
	ghost_mat.albedo_color = Color(1, 1, 1, 0.4)
	ghost_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	ghost_mat.no_depth_test = true
	_ghost_mesh.material_override = ghost_mat
	add_child(_ghost_mesh)
	_ghost_mesh.visible = false


func _process(_delta: float) -> void:
	if current_mode == Mode.NONE:
		_ghost_mesh.visible = false
		return
	var ray := _get_interaction_ray()
	if ray != null and ray.is_colliding():
		var hit_point := ray.get_collision_point()
		var hit_normal := ray.get_collision_normal()
		if current_mode == Mode.VOXEL:
			var place_pos := _snap_to_voxel(hit_point + hit_normal * 0.5)
			_ghost_mesh.position = Vector3(float(place_pos.x) + 0.5, float(place_pos.y) + 0.5, float(place_pos.z) + 0.5)
			_ghost_mesh.scale = Vector3.ONE
			_ghost_mesh.mesh = _create_cube_mesh()
			_ghost_mesh.visible = true
		elif current_mode == Mode.PREFAB:
			var place_pos := _snap_to_voxel(hit_point + hit_normal * 0.5)
			var prefab_data: Dictionary = PrefabRegistry.get_prefab(selected_prefab_name)
			if prefab_data.size() > 0:
				_ghost_mesh.position = Vector3(float(place_pos.x), float(place_pos.y), float(place_pos.z))
				var sz: Vector3i = prefab_data["size"]
				_ghost_mesh.scale = Vector3(float(sz.x), float(sz.y), float(sz.z))
				_ghost_mesh.mesh = _create_cube_mesh()
				_ghost_mesh.visible = true
	else:
		_ghost_mesh.visible = false


func toggle_menu() -> void:
	_menu_visible = not _menu_visible
	if _menu_visible:
		current_mode = Mode.VOXEL
		build_mode_changed.emit("voxel")
	else:
		current_mode = Mode.NONE
		build_mode_changed.emit("none")
		_ghost_mesh.visible = false


func select_voxel(type_val: int) -> void:
	selected_voxel_type = type_val
	current_mode = Mode.VOXEL
	selected_block_changed.emit(type_val)
	build_mode_changed.emit("voxel")


func select_prefab(prefab_name: String) -> void:
	selected_prefab_name = prefab_name
	current_mode = Mode.PREFAB
	selected_prefab_changed.emit(prefab_name)
	build_mode_changed.emit("prefab")


func place_at(hit_point: Vector3, hit_normal: Vector3) -> void:
	var engine := _get_voxel_engine()
	if engine == null:
		return
	if current_mode == Mode.VOXEL:
		var pos := _snap_to_voxel(hit_point + hit_normal * 0.5)
		engine.set_voxel(pos, selected_voxel_type)
	elif current_mode == Mode.PREFAB:
		var origin := _snap_to_voxel(hit_point + hit_normal * 0.5)
		var prefab_data: Dictionary = PrefabRegistry.get_prefab(selected_prefab_name)
		if prefab_data.size() > 0:
			engine.stamp_prefab(origin, prefab_data["voxels"], prefab_data["size"])


func destroy_at(hit_point: Vector3, hit_normal: Vector3) -> void:
	var engine := _get_voxel_engine()
	if engine == null:
		return
	var pos := _snap_to_voxel(hit_point - hit_normal * 0.5)
	engine.set_voxel(pos, 0)


func _snap_to_voxel(world_pos: Vector3) -> Vector3i:
	return Vector3i(
		int(floor(world_pos.x)),
		int(floor(world_pos.y)),
		int(floor(world_pos.z))
	)


func _get_voxel_engine() -> Node3D:
	if _voxel_engine == null or not is_instance_valid(_voxel_engine):
		_voxel_engine = get_node_or_null("/root/Main/World/VoxelEngine")
	return _voxel_engine


func _get_interaction_ray() -> RayCast3D:
	var controller := get_parent()
	if controller != null and controller.has_method("get_interaction_ray"):
		return controller.get_interaction_ray()
	return null


func _create_cube_mesh() -> BoxMesh:
	var mesh := BoxMesh.new()
	mesh.size = Vector3(1.0, 1.0, 1.0)
	return mesh