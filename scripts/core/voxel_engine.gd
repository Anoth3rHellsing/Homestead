extends Node3D

## VoxelEngine — Manages chunk loading/unloading, voxel access across chunks,
## and coordinates mesh rebuilding. Attached to the world root node.

signal voxel_changed(world_pos: Vector3i, old_type: int, new_type: int)
signal chunk_loaded(chunk_pos: Vector3i)
signal chunk_unloaded(chunk_pos: Vector3i)

const CHUNK_SIZE := 16
const RENDER_DISTANCE := 3
const MAX_CHUNKS_PER_FRAME := 16

var _chunks: Dictionary = {}
var _rebuild_queue: Array = []
var _player_chunk: Vector3i = Vector3i(-999, -999, -999)
var chunk_script: GDScript = null


func _ready() -> void:
	chunk_script = load("res://scripts/core/chunk.gd")
	_update_chunks_around(Vector3i.ZERO)
	GameManager.register_voxel_engine(self)


func _process(_delta: float) -> void:
	var rebuilt: int = 0
	while _rebuild_queue.size() > 0 and rebuilt < MAX_CHUNKS_PER_FRAME:
		var pos: Vector3i = _rebuild_queue.pop_front()
		if _chunks.has(pos):
			_chunks[pos].rebuild_mesh()
			rebuilt = rebuilt + 1


func update_player_position(player_pos: Vector3) -> void:
	var new_chunk: Vector3i = Vector3i(
		int(floor(player_pos.x / float(CHUNK_SIZE))),
		int(floor(player_pos.y / float(CHUNK_SIZE))),
		int(floor(player_pos.z / float(CHUNK_SIZE)))
	)
	if new_chunk != _player_chunk:
		_player_chunk = new_chunk
		_update_chunks_around(new_chunk)


func get_voxel(world_pos: Vector3i) -> int:
	var chunk_pos: Vector3i = _world_to_chunk(world_pos)
	if not _chunks.has(chunk_pos):
		return 0
	var local: Vector3i = _world_to_local(world_pos, chunk_pos)
	return _chunks[chunk_pos].get_voxel(local.x, local.y, local.z)


func set_voxel(world_pos: Vector3i, type_val: int) -> void:
	var chunk_pos: Vector3i = _world_to_chunk(world_pos)
	if not _chunks.has(chunk_pos):
		_load_chunk(chunk_pos)
	var local: Vector3i = _world_to_local(world_pos, chunk_pos)
	var old_type: int = _chunks[chunk_pos].get_voxel(local.x, local.y, local.z)
	_chunks[chunk_pos].set_voxel(local.x, local.y, local.z, type_val)
	if not _rebuild_queue.has(chunk_pos):
		_rebuild_queue.append(chunk_pos)
	_check_neighbor_rebuild(world_pos, chunk_pos)
	voxel_changed.emit(world_pos, old_type, type_val)


func set_voxels_batch(positions: Array, types: Array) -> void:
	var affected_chunks: Dictionary = {}
	for i in range(positions.size()):
		var world_pos: Vector3i = positions[i]
		var type_val: int = types[i]
		var chunk_pos: Vector3i = _world_to_chunk(world_pos)
		if not _chunks.has(chunk_pos):
			_load_chunk(chunk_pos)
		var local: Vector3i = _world_to_local(world_pos, chunk_pos)
		_chunks[chunk_pos].set_voxel(local.x, local.y, local.z, type_val)
		affected_chunks[chunk_pos] = true
	for chunk_pos in affected_chunks:
		if not _rebuild_queue.has(chunk_pos):
			_rebuild_queue.append(chunk_pos)


func get_chunk(chunk_pos: Vector3i) -> Node3D:
	if _chunks.has(chunk_pos):
		return _chunks[chunk_pos]
	return null


func is_chunk_loaded(chunk_pos: Vector3i) -> bool:
	return _chunks.has(chunk_pos)


func stamp_prefab(origin: Vector3i, voxel_data: PackedByteArray, size: Vector3i) -> void:
	var positions: Array = []
	var types: Array = []
	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				var idx: int = x + y * size.x + z * size.x * size.y
				if idx < voxel_data.size():
					var vtype: int = voxel_data[idx]
					if vtype != 0:
						positions.append(Vector3i(origin.x + x, origin.y + y, origin.z + z))
						types.append(vtype)
	set_voxels_batch(positions, types)


func _update_chunks_around(center: Vector3i) -> void:
	var needed: Dictionary = {}
	for x in range(center.x - RENDER_DISTANCE, center.x + RENDER_DISTANCE + 1):
		for y in range(center.y - 1, center.y + 2):
			for z in range(center.z - RENDER_DISTANCE, center.z + RENDER_DISTANCE + 1):
				var pos: Vector3i = Vector3i(x, y, z)
				needed[pos] = true
				if not _chunks.has(pos):
					_load_chunk(pos)
	var to_remove: Array = []
	for pos in _chunks:
		if not needed.has(pos):
			to_remove.append(pos)
	for pos in to_remove:
		_unload_chunk(pos)


func _load_chunk(pos: Vector3i) -> void:
	if _chunks.has(pos):
		return
	var chunk: Node3D = Node3D.new()
	chunk.set_script(chunk_script)
	add_child(chunk)
	chunk.initialize(pos)
	_chunks[pos] = chunk
	if not _rebuild_queue.has(pos):
		_rebuild_queue.append(pos)
	chunk_loaded.emit(pos)


func _unload_chunk(pos: Vector3i) -> void:
	if not _chunks.has(pos):
		return
	var chunk: Node3D = _chunks[pos]
	chunk.queue_free()
	_chunks.erase(pos)
	_rebuild_queue.erase(pos)
	chunk_unloaded.emit(pos)


func _check_neighbor_rebuild(world_pos: Vector3i, chunk_pos: Vector3i) -> void:
	var local: Vector3i = _world_to_local(world_pos, chunk_pos)
	var neighbors: Array = []
	if local.x == 0:
		neighbors.append(Vector3i(chunk_pos.x - 1, chunk_pos.y, chunk_pos.z))
	elif local.x == CHUNK_SIZE - 1:
		neighbors.append(Vector3i(chunk_pos.x + 1, chunk_pos.y, chunk_pos.z))
	if local.y == 0:
		neighbors.append(Vector3i(chunk_pos.x, chunk_pos.y - 1, chunk_pos.z))
	elif local.y == CHUNK_SIZE - 1:
		neighbors.append(Vector3i(chunk_pos.x, chunk_pos.y + 1, chunk_pos.z))
	if local.z == 0:
		neighbors.append(Vector3i(chunk_pos.x, chunk_pos.y, chunk_pos.z - 1))
	elif local.z == CHUNK_SIZE - 1:
		neighbors.append(Vector3i(chunk_pos.x, chunk_pos.y, chunk_pos.z + 1))
	for npos in neighbors:
		if _chunks.has(npos) and not _rebuild_queue.has(npos):
			_rebuild_queue.append(npos)


func _world_to_chunk(world_pos: Vector3i) -> Vector3i:
	return Vector3i(
		int(floor(float(world_pos.x) / float(CHUNK_SIZE))),
		int(floor(float(world_pos.y) / float(CHUNK_SIZE))),
		int(floor(float(world_pos.z) / float(CHUNK_SIZE)))
	)


func _world_to_local(world_pos: Vector3i, chunk_pos: Vector3i) -> Vector3i:
	return Vector3i(
		world_pos.x - chunk_pos.x * CHUNK_SIZE,
		world_pos.y - chunk_pos.y * CHUNK_SIZE,
		world_pos.z - chunk_pos.z * CHUNK_SIZE
	)