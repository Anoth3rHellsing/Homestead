extends Node

## WaterSimulator — Graph-based water network simulation with pressure, flow,
## treatment, and recycling. Ticks at 2 Hz via GameManager.
## Uses dictionaries instead of inner classes for Godot 4.7 compatibility.

signal network_updated(network_id: int)
signal pressure_changed(node_key: Vector3i, pressure: float)
signal flow_changed(pipe_key: String, flow: float)

var _nodes: Dictionary = {}
var _edges: Dictionary = {}
var _networks: Array = []
var _tick_count: int = 0


func _make_node(pos: Vector3i, vtype: int) -> Dictionary:
	var is_src: bool = VoxelTypes.is_water_producer(vtype)
	var cap: float = 0.0
	var stored_val: float = 0.0
	if vtype == VoxelTypes.Type.RESERVOIR:
		cap = 100.0
	elif vtype == VoxelTypes.Type.WATER_SOURCE:
		is_src = true
		cap = 50.0
		stored_val = 50.0
	return {
		"position": pos,
		"type": vtype,
		"pressure": 0.0,
		"capacity": cap,
		"stored": stored_val,
		"is_source": is_src,
		"is_pump": vtype == VoxelTypes.Type.PUMP,
		"is_valve": vtype == VoxelTypes.Type.VALVE,
		"is_treatment": vtype == VoxelTypes.Type.TREATMENT_PLANT,
		"valve_open": true,
		"treatment_progress": 0.0,
		"treatment_rate": 10.0,
		"pump_pressure": 15.0,
		"connected_edges": [],
	}


func _make_edge(from_p: Vector3i, to_p: Vector3i, ptype: int) -> Dictionary:
	var max_f: float = 10.0
	var fric: float = 0.1
	if ptype == VoxelTypes.Type.PIPE_IRON:
		max_f = 20.0
		fric = 0.05
	var key_str: String = "%d,%d,%d->%d,%d,%d" % [from_p.x, from_p.y, from_p.z, to_p.x, to_p.y, to_p.z]
	return {
		"from_pos": from_p,
		"to_pos": to_p,
		"pipe_type": ptype,
		"flow": 0.0,
		"max_flow": max_f,
		"friction": fric,
		"key": key_str,
	}


func _ready() -> void:
	GameManager.register_water_simulator(self)
	GameManager.water_tick.connect(_on_water_tick)


func _on_water_tick() -> void:
	_tick_count += 1
	_rebuild_graph_if_needed()
	_resolve_networks()
	_update_treatment_plants()


func register_water_node(pos: Vector3i, voxel_type: int) -> void:
	if not VoxelTypes.connects_to_pipe(voxel_type):
		return
	_nodes[pos] = _make_node(pos, voxel_type)
	_discover_connections(pos)


func unregister_water_node(pos: Vector3i) -> void:
	if _nodes.has(pos):
		var node: Dictionary = _nodes[pos]
		var edge_list: Array = node["connected_edges"]
		for edge_key in edge_list:
			_edges.erase(edge_key)
		_nodes.erase(pos)


func get_pressure_at(pos: Vector3i) -> float:
	if _nodes.has(pos):
		return _nodes[pos]["pressure"]
	return 0.0


func get_flow_between(from_pos: Vector3i, to_pos: Vector3i) -> float:
	var key_str: String = "%d,%d,%d->%d,%d,%d" % [from_pos.x, from_pos.y, from_pos.z, to_pos.x, to_pos.y, to_pos.z]
	if _edges.has(key_str):
		return _edges[key_str]["flow"]
	return 0.0


func set_valve_state(pos: Vector3i, open_valve: bool) -> void:
	if _nodes.has(pos) and _nodes[pos]["is_valve"]:
		_nodes[pos]["valve_open"] = open_valve


func get_debug_data() -> Dictionary:
	var node_data: Array = []
	for pos in _nodes:
		var n: Dictionary = _nodes[pos]
		node_data.append({
			"pos": pos,
			"type": VoxelTypes.get_type_name(n["type"]),
			"pressure": n["pressure"],
			"is_source": n["is_source"],
			"is_pump": n["is_pump"],
		})
	var edge_data: Array = []
	for key_str in _edges:
		var e: Dictionary = _edges[key_str]
		edge_data.append({
			"key": key_str,
			"flow": e["flow"],
			"max_flow": e["max_flow"],
		})
	return {"nodes": node_data, "edges": edge_data, "tick": _tick_count}


func _rebuild_graph_if_needed() -> void:
	_edges.clear()
	for pos in _nodes:
		_nodes[pos]["connected_edges"] = []
		_discover_connections(pos)


func _discover_connections(pos: Vector3i) -> void:
	if not _nodes.has(pos):
		return
	var directions: Array = [
		Vector3i(1, 0, 0), Vector3i(-1, 0, 0),
		Vector3i(0, 1, 0), Vector3i(0, -1, 0),
		Vector3i(0, 0, 1), Vector3i(0, 0, -1),
	]
	for dir_vec in directions:
		var neighbor_pos: Vector3i = pos + dir_vec
		if _nodes.has(neighbor_pos):
			var edge_key: String = "%d,%d,%d->%d,%d,%d" % [pos.x, pos.y, pos.z, neighbor_pos.x, neighbor_pos.y, neighbor_pos.z]
			if not _edges.has(edge_key):
				var pipe_type: int = _nodes[pos]["type"]
				if VoxelTypes.connects_to_pipe(pipe_type):
					var edge: Dictionary = _make_edge(pos, neighbor_pos, pipe_type)
					_edges[edge_key] = edge
					_nodes[pos]["connected_edges"].append(edge_key)
					_nodes[neighbor_pos]["connected_edges"].append(edge_key)


func _resolve_networks() -> void:
	var visited: Dictionary = {}
	_networks.clear()
	for start_pos in _nodes:
		if visited.has(start_pos):
			continue
		var component_nodes: Array = []
		var queue: Array = [start_pos]
		visited[start_pos] = true
		while queue.size() > 0:
			var current: Vector3i = queue.pop_front()
			component_nodes.append(current)
			if _nodes.has(current):
				var node: Dictionary = _nodes[current]
				var edge_list: Array = node["connected_edges"]
				for edge_key in edge_list:
					if _edges.has(edge_key):
						var edge: Dictionary = _edges[edge_key]
						var other: Vector3i
						if edge["from_pos"] == current:
							other = edge["to_pos"]
						else:
							other = edge["from_pos"]
						if not visited.has(other) and _nodes.has(other):
							if _nodes[current]["is_valve"] and not _nodes[current]["valve_open"]:
								continue
							if _nodes[other]["is_valve"] and not _nodes[other]["valve_open"]:
								continue
							visited[other] = true
							queue.append(other)
		if component_nodes.size() > 0:
			_networks.append({"nodes": component_nodes})
	for network in _networks:
		_resolve_single_network(network["nodes"])


func _resolve_single_network(node_positions: Array) -> void:
	for pos in node_positions:
		var node: Dictionary = _nodes[pos]
		if node["is_source"]:
			node["pressure"] = 10.0
			node["stored"] = minf(node["stored"] + 5.0, node["capacity"])
	for pos in node_positions:
		var node: Dictionary = _nodes[pos]
		if node["is_pump"]:
			node["pressure"] = node["pressure"] + node["pump_pressure"]
	var new_pressures: Dictionary = {}
	for pos in node_positions:
		var node: Dictionary = _nodes[pos]
		if node["is_source"] or node["is_pump"]:
			new_pressures[pos] = node["pressure"]
			continue
		var total_pressure: float = 0.0
		var count: int = 0
		var edge_list: Array = node["connected_edges"]
		for edge_key in edge_list:
			if _edges.has(edge_key):
				var edge: Dictionary = _edges[edge_key]
				var other_pos: Vector3i
				if edge["from_pos"] == pos:
					other_pos = edge["to_pos"]
				else:
					other_pos = edge["from_pos"]
				if _nodes.has(other_pos):
					total_pressure = total_pressure + _nodes[other_pos]["pressure"] * (1.0 - edge["friction"])
					count = count + 1
		if count > 0:
			new_pressures[pos] = total_pressure / float(count)
		else:
			new_pressures[pos] = 0.0
	for pos in new_pressures:
		if _nodes.has(pos):
			_nodes[pos]["pressure"] = new_pressures[pos]
			pressure_changed.emit(pos, new_pressures[pos])
	for edge_key in _edges:
		var edge: Dictionary = _edges[edge_key]
		if not _nodes.has(edge["from_pos"]) or not _nodes.has(edge["to_pos"]):
			continue
		var from_node: Dictionary = _nodes[edge["from_pos"]]
		var to_node: Dictionary = _nodes[edge["to_pos"]]
		if from_node["is_valve"] and not from_node["valve_open"]:
			edge["flow"] = 0.0
			continue
		if to_node["is_valve"] and not to_node["valve_open"]:
			edge["flow"] = 0.0
			continue
		var pressure_diff: float = from_node["pressure"] - to_node["pressure"]
		var height_diff: float = float(edge["from_pos"].y - edge["to_pos"].y)
		var effective_diff: float = pressure_diff + height_diff * 0.5
		edge["flow"] = clampf(effective_diff * 2.0, -edge["max_flow"], edge["max_flow"])
		flow_changed.emit(edge_key, edge["flow"])
	for pos in node_positions:
		var node: Dictionary = _nodes[pos]
		if node["capacity"] > 0.0:
			var net_inflow: float = 0.0
			var edge_list: Array = node["connected_edges"]
			for edge_key in edge_list:
				if _edges.has(edge_key):
					var edge: Dictionary = _edges[edge_key]
					if edge["to_pos"] == pos:
						net_inflow = net_inflow + edge["flow"]
					elif edge["from_pos"] == pos:
						net_inflow = net_inflow - edge["flow"]
			node["stored"] = clampf(node["stored"] + net_inflow * 0.5, 0.0, node["capacity"])


func _update_treatment_plants() -> void:
	for pos in _nodes:
		var node: Dictionary = _nodes[pos]
		if node["is_treatment"] and node["pressure"] > 1.0:
			node["treatment_progress"] = node["treatment_progress"] + node["treatment_rate"] * GameManager.WATER_TICK_INTERVAL
			if node["treatment_progress"] >= 100.0:
				node["treatment_progress"] = 0.0