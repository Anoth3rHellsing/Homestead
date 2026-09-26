extends Node3D
## Chunk — Represents a 16x16x16 block of voxels.
## Handles local data storage, mesh generation, and collision.
## Uses TerrainGenerator for procedural world generation.

const CHUNK_SIZE := 16

signal chunk_mesh_updated

var voxels: PackedByteArray = PackedByteArray()
var is_dirty: bool = true
var chunk_position: Vector3i = Vector3i.ZERO
var _mesh_instance: MeshInstance3D = null
var _collision_body: StaticBody3D = null
var _collision_shape: CollisionShape3D = null
var _terrain_gen: Node = null


func _ready() -> void:
	voxels.resize(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE)
	voxels.fill(0)
	_mesh_instance = MeshInstance3D.new()
	add_child(_mesh_instance)
	_collision_body = StaticBody3D.new()
	_collision_body.collision_layer = 1
	add_child(_collision_body)
	_collision_shape = CollisionShape3D.new()
	_collision_body.add_child(_collision_shape)


func initialize(pos: Vector3i, data: PackedByteArray = PackedByteArray()) -> void:
	chunk_position = pos
	position = Vector3(float(pos.x * CHUNK_SIZE), float(pos.y * CHUNK_SIZE), float(pos.z * CHUNK_SIZE))
	if data.size() == CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE:
		voxels = data
	else:
		_generate_terrain()
	is_dirty = true


func _generate_terrain() -> void:
	var terrain_gen = _get_terrain_generator()
	if terrain_gen != null and terrain_gen.has_method("generate_chunk_data"):
		voxels = terrain_gen.generate_chunk_data(chunk_position)
	else:
		_generate_fallback_terrain()


func _get_terrain_generator() -> Node:
	if _terrain_gen == null or not is_instance_valid(_terrain_gen):
		_terrain_gen = get_node_or_null("/root/TerrainGenerator")
	return _terrain_gen


func _generate_fallback_terrain() -> void:
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var world_x: int = chunk_position.x * CHUNK_SIZE + x
			var world_z: int = chunk_position.z * CHUNK_SIZE + z
			var height: int = int(4.0 + 2.0 * sin(float(world_x) * 0.1) + 2.0 * cos(float(world_z) * 0.1))
			if height < 0:
				height = 0
			if height >= CHUNK_SIZE:
				height = CHUNK_SIZE - 1
			for y in range(CHUNK_SIZE):
				var idx: int = _get_index(x, y, z)
				if y < height - 2:
					voxels[idx] = 2
				elif y <= height:
					voxels[idx] = 1
				else:
					voxels[idx] = 0


func get_voxel(x: int, y: int, z: int) -> int:
	if x < 0 or x >= CHUNK_SIZE or y < 0 or y >= CHUNK_SIZE or z < 0 or z >= CHUNK_SIZE:
		return 0
	return voxels[_get_index(x, y, z)]


func set_voxel(x: int, y: int, z: int, type_val: int) -> void:
	if x < 0 or x >= CHUNK_SIZE or y < 0 or y >= CHUNK_SIZE or z < 0 or z >= CHUNK_SIZE:
		return
	voxels[_get_index(x, y, z)] = type_val
	is_dirty = true


func _get_index(x: int, y: int, z: int) -> int:
	return x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE


func rebuild_mesh() -> void:
	if not is_dirty:
		return
	var verts: PackedVector3Array = PackedVector3Array()
	var norms: PackedVector3Array = PackedVector3Array()
	var cols: PackedColorArray = PackedColorArray()
	_build_faces(verts, norms, cols)
	if verts.size() == 0:
		_mesh_instance.mesh = null
		_collision_shape.shape = null
		is_dirty = false
		chunk_mesh_updated.emit()
		return
	var arr_mesh: ArrayMesh = ArrayMesh.new()
	var surface_arrays: Array = []
	surface_arrays.resize(Mesh.ARRAY_MAX)
	surface_arrays[Mesh.ARRAY_VERTEX] = verts
	surface_arrays[Mesh.ARRAY_NORMAL] = norms
	surface_arrays[Mesh.ARRAY_COLOR] = cols
	arr_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, surface_arrays)
	_mesh_instance.mesh = arr_mesh
	# Build collision separately - use simplified box shapes instead of trimesh
	# to avoid rendering artifacts
	_build_collision_simple()
	is_dirty = false
	chunk_mesh_updated.emit()


func _build_collision_simple() -> void:
	# Remove old collision children
	for child in _collision_body.get_children():
		child.queue_free()
	# Create simple box collision for the chunk bounding box
	var shape := BoxShape3D.new()
	shape.size = Vector3(CHUNK_SIZE, CHUNK_SIZE, CHUNK_SIZE)
	var col_shape := CollisionShape3D.new()
	col_shape.shape = shape
	col_shape.position = Vector3(CHUNK_SIZE / 2.0, CHUNK_SIZE / 2.0, CHUNK_SIZE / 2.0)
	_collision_body.add_child(col_shape)


func _build_faces(verts: PackedVector3Array, norms: PackedVector3Array, cols: PackedColorArray) -> void:
	var dx: Array = [1, -1, 0, 0, 0, 0]
	var dy: Array = [0, 0, 1, -1, 0, 0]
	var dz: Array = [0, 0, 0, 0, 1, -1]
	var nx_arr: Array = [1.0, -1.0, 0.0, 0.0, 0.0, 0.0]
	var ny_arr: Array = [0.0, 0.0, 1.0, -1.0, 0.0, 0.0]
	var nz_arr: Array = [0.0, 0.0, 0.0, 0.0, 1.0, -1.0]
	# Face brightness multipliers for ambient occlusion-like effect
	var face_brightness: Array = [0.85, 0.85, 1.0, 0.5, 0.75, 0.75]
	for x in range(CHUNK_SIZE):
		for y in range(CHUNK_SIZE):
			for z in range(CHUNK_SIZE):
				var vtype: int = voxels[_get_index(x, y, z)]
				if vtype == 0:
					continue
				if not VoxelTypes.is_solid(vtype):
					continue
				var base_color: Color = VoxelTypes.get_color(vtype)
				# Add height-based color variation for terrain
				var world_y: int = chunk_position.y * CHUNK_SIZE + y
				if vtype == 1: # DIRT - add green tint on surface
					var above_idx: int = _get_index_safe(x, y + 1, z)
					if above_idx >= 0 and voxels[above_idx] == 0:
						base_color = Color(0.35, 0.55, 0.25) # grass green
					elif world_y < 3:
						base_color = Color(0.4, 0.3, 0.18) # darker underground
				elif vtype == 2: # STONE - vary by depth
					var depth_factor: float = float(world_y) / 16.0
					base_color = base_color.lerp(Color(0.35, 0.35, 0.33), depth_factor * 0.3)
				elif vtype == 13: # WATER - animated-ish color
					base_color = Color(0.25, 0.45, 0.7, 0.8)
				for f in range(6):
					var neighbor_x: int = x + int(dx[f])
					var neighbor_y: int = y + int(dy[f])
					var neighbor_z: int = z + int(dz[f])
					var neighbor_type: int = 0
					if neighbor_x >= 0 and neighbor_x < CHUNK_SIZE and neighbor_y >= 0 and neighbor_y < CHUNK_SIZE and neighbor_z >= 0 and neighbor_z < CHUNK_SIZE:
						neighbor_type = voxels[_get_index(neighbor_x, neighbor_y, neighbor_z)]
					if neighbor_type != 0 and not VoxelTypes.is_transparent(neighbor_type):
						continue
					var normal: Vector3 = Vector3(float(nx_arr[f]), float(ny_arr[f]), float(nz_arr[f]))
					var brightness: float = face_brightness[f]
					var face_color: Color = Color(
						base_color.r * brightness,
						base_color.g * brightness,
						base_color.b * brightness,
						base_color.a
					)
					_add_face_verts(verts, cols, x, y, z, f, face_color)
					for vi in range(6):
						norms.append(normal)


func _get_index_safe(x: int, y: int, z: int) -> int:
	if x < 0 or x >= CHUNK_SIZE or y < 0 or y >= CHUNK_SIZE or z < 0 or z >= CHUNK_SIZE:
		return -1
	return x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE


func _add_face_verts(verts: PackedVector3Array, cols: PackedColorArray, x: int, y: int, z: int, face: int, color: Color) -> void:
	var fx: float = float(x)
	var fy: float = float(y)
	var fz: float = float(z)
	if face == 0:
		verts.append(Vector3(fx+1, fy, fz))
		verts.append(Vector3(fx+1, fy+1, fz))
		verts.append(Vector3(fx+1, fy+1, fz+1))
		verts.append(Vector3(fx+1, fy, fz))
		verts.append(Vector3(fx+1, fy+1, fz+1))
		verts.append(Vector3(fx+1, fy, fz+1))
	elif face == 1:
		verts.append(Vector3(fx, fy, fz+1))
		verts.append(Vector3(fx, fy+1, fz+1))
		verts.append(Vector3(fx, fy+1, fz))
		verts.append(Vector3(fx, fy, fz+1))
		verts.append(Vector3(fx, fy+1, fz))
		verts.append(Vector3(fx, fy, fz))
	elif face == 2:
		verts.append(Vector3(fx, fy+1, fz))
		verts.append(Vector3(fx, fy+1, fz+1))
		verts.append(Vector3(fx+1, fy+1, fz+1))
		verts.append(Vector3(fx, fy+1, fz))
		verts.append(Vector3(fx+1, fy+1, fz+1))
		verts.append(Vector3(fx+1, fy+1, fz))
	elif face == 3:
		verts.append(Vector3(fx, fy, fz+1))
		verts.append(Vector3(fx, fy, fz))
		verts.append(Vector3(fx+1, fy, fz))
		verts.append(Vector3(fx, fy, fz+1))
		verts.append(Vector3(fx+1, fy, fz))
		verts.append(Vector3(fx+1, fy, fz+1))
	elif face == 4:
		verts.append(Vector3(fx, fy, fz+1))
		verts.append(Vector3(fx+1, fy, fz+1))
		verts.append(Vector3(fx+1, fy+1, fz+1))
		verts.append(Vector3(fx, fy, fz+1))
		verts.append(Vector3(fx+1, fy+1, fz+1))
		verts.append(Vector3(fx, fy+1, fz+1))
	elif face == 5:
		verts.append(Vector3(fx+1, fy, fz))
		verts.append(Vector3(fx, fy, fz))
		verts.append(Vector3(fx, fy+1, fz))
		verts.append(Vector3(fx+1, fy, fz))
		verts.append(Vector3(fx, fy+1, fz))
		verts.append(Vector3(fx+1, fy+1, fz))
	for i in range(6):
		cols.append(color)


func serialize() -> Dictionary:
	return {
		"position": {"x": chunk_position.x, "y": chunk_position.y, "z": chunk_position.z},
		"data": voxels.duplicate(),
	}


func deserialize(data: Dictionary) -> void:
	var p: Dictionary = data["position"]
	chunk_position = Vector3i(int(p["x"]), int(p["y"]), int(p["z"]))
	position = Vector3(float(chunk_position.x * CHUNK_SIZE), float(chunk_position.y * CHUNK_SIZE), float(chunk_position.z * CHUNK_SIZE))
	voxels = PackedByteArray(data["data"])
	is_dirty = true