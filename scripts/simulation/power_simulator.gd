extends Node

## PowerSimulator — Steam and electrical power network simulation.
## Uses dictionaries instead of inner classes for Godot 4.7 compatibility.

signal power_network_updated()
signal building_powered(pos: Vector3i, powered: bool)

var _nodes: Dictionary = {}
var _edges: Dictionary = {}


func _make_node(pos: Vector3i, vtype: int) -> Dictionary:
	return {
		"position": pos,
		"type": vtype,
		"is_producer": VoxelTypes.is_steam_emitter(vtype) or vtype == VoxelTypes.Type.GENERATOR,
		"is_consumer": VoxelTypes.is_power_consumer(vtype),
		"production": 0.0,
		"consumption": 0.0,
		"powered": false,
		"connected_edges": [],
	}


func _make_edge(from_p: Vector3i, to_p: Vector3i) -> Dictionary:
	var key_str: String = "%d,%d,%d->%d,%d,%d" % [from_p.x, from_p.y, from_p.z, to_p.x, to_p.y, to_p.z]
	return {
		"from_pos": from_p,
		"to_pos": to_p,
		"key": key_str,
	}


func _ready() -> void:
	GameManager.register_power_simulator(self)
	GameManager.power_tick.connect(_on_power_tick)


func _on_power_tick() -> void:
	_rebuild_graph()
	_resolve_power_distribution()
	power_network_updated.emit()


func register_power_node(pos: Vector3i, voxel_type: int) -> void:
	if not VoxelTypes.is_steam_emitter(voxel_type) and not VoxelTypes.is_power_consumer(voxel_type):
		return
	_nodes[pos] = _make_node(pos, voxel_type)


func unregister_power_node(pos: Vector3i) -> void:
	if _nodes.has(pos):
		var node: Dictionary = _nodes[pos]
		var edge_list: Array = node["connected_edges"]
		for edge_key in edge_list:
			_edges.erase(edge_key)
		_nodes.erase(pos)


func is_building_powered(pos: Vector3i) -> bool:
	if _nodes.has(pos):
		return _nodes[pos]["powered"]
	return false


func get_debug_data() -> Dictionary:
	var node_data: Array = []
	for pos in _nodes:
		var n: Dictionary = _nodes[pos]
		node_data.append({
			"pos": pos,
			"type": VoxelTypes.get_type_name(n["type"]),
			"producer": n["is_producer"],
			"consumer": n["is_consumer"],
			"powered": n["powered"],
		})
	return {"nodes": node_data}


func _rebuild_graph() -> void:
	_edges.clear()
	for pos in _nodes:
		_nodes[pos]["connected_edges"] = []
	var directions: Array = [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1),
	]
	for pos in _nodes:
		for dir_vec in directions:
			var neighbor: Vector3i = pos + dir_vec
			if _nodes.has(neighbor):
				var key_str: String = "%d,%d,%d->%d,%d,%d" % [pos.x, pos.y, pos.z, neighbor.x, neighbor.y, neighbor.z]
				if not _edges.has(key_str):
					var edge: Dictionary = _make_edge(pos, neighbor)
					_edges[key_str] = edge
					_nodes[pos]["connected_edges"].append(key_str)
					_nodes[neighbor]["connected_edges"].append(key_str)


func _resolve_power_distribution() -> void:
	var visited: Dictionary = {}
	for start_pos in _nodes:
		var node: Dictionary = _nodes[start_pos]
		if not node["is_producer"]:
			continue
		if visited.has(start_pos):
			continue
		var queue: Array = [start_pos]
		visited[start_pos] = true
		while queue.size() > 0:
			var current: Vector3i = queue.pop_front()
			var current_node: Dictionary = _nodes[current]
			if current_node["is_consumer"]:
				current_node["powered"] = true
				building_powered.emit(current, true)
			var edge_list: Array = current_node["connected_edges"]
			for edge_key in edge_list:
				if _edges.has(edge_key):
					var edge: Dictionary = _edges[edge_key]
					var other: Vector3i
					if edge["from_pos"] == current:
						other = edge["to_pos"]
					else:
						other = edge["from_pos"]
					if not visited.has(other) and _nodes.has(other):
						visited[other] = true
						queue.append(other)
	for pos in _nodes:
		var node: Dictionary = _nodes[pos]
		if node["is_consumer"] and not visited.has(pos):
			node["powered"] = false
			building_powered.emit(pos, false)