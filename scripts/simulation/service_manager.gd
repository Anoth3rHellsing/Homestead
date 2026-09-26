extends Node

## ServiceManager — Handles waste collection, citizen satisfaction,
## and basic service routing. Uses dictionaries for Godot 4.7 compatibility.

signal service_updated()
signal building_serviced(pos: Vector3i, service_type: String, level: float)

var _buildings: Dictionary = {}
var _waste_collectors: Array = []


func _make_building(pos: Vector3i, vtype: int) -> Dictionary:
	return {
		"position": pos,
		"type": vtype,
		"has_water": false,
		"has_power": false,
		"has_waste_service": false,
		"waste_accumulated": 0.0,
		"satisfaction": 100.0,
		"population": 0,
		"last_service_tick": 0,
	}


func _ready() -> void:
	GameManager.register_service_manager(self)
	GameManager.service_tick.connect(_on_service_tick)
	GameManager.building_tick.connect(_on_building_tick)
	GameManager.citizen_tick.connect(_on_citizen_tick)
	for i in range(3):
		_waste_collectors.append({
			"id": i,
			"position": Vector3.ZERO,
			"capacity": 50.0,
			"current_load": 0.0,
			"target": null,
		})


func register_building(pos: Vector3i, voxel_type: int) -> void:
	_buildings[pos] = _make_building(pos, voxel_type)


func unregister_building(pos: Vector3i) -> void:
	_buildings.erase(pos)


func get_building_satisfaction(pos: Vector3i) -> float:
	if _buildings.has(pos):
		return _buildings[pos]["satisfaction"]
	return 0.0


func get_total_population() -> int:
	var total: int = 0
	for pos in _buildings:
		total = total + _buildings[pos]["population"]
	return total


func get_city_satisfaction() -> float:
	if _buildings.size() == 0:
		return 100.0
	var total: float = 0.0
	var count: int = 0
	for pos in _buildings:
		total = total + _buildings[pos]["satisfaction"]
		count = count + 1
	return total / float(count)


func get_debug_data() -> Dictionary:
	var building_data: Array = []
	for pos in _buildings:
		var b: Dictionary = _buildings[pos]
		building_data.append({
			"pos": pos,
			"type": VoxelTypes.get_type_name(b["type"]),
			"satisfaction": b["satisfaction"],
			"water": b["has_water"],
			"power": b["has_power"],
			"waste_service": b["has_waste_service"],
			"waste": b["waste_accumulated"],
			"population": b["population"],
		})
	return {"buildings": building_data, "collectors": _waste_collectors.size()}


func _on_service_tick() -> void:
	_run_waste_collection()
	service_updated.emit()


func _on_building_tick() -> void:
	_update_building_services()


func _on_citizen_tick() -> void:
	_update_population_and_satisfaction()
	GameManager.total_population = get_total_population()
	GameManager.city_satisfaction = get_city_satisfaction()


func _update_building_services() -> void:
	var water_sim = GameManager.water_simulator
	var power_sim = GameManager.power_simulator
	for pos in _buildings:
		var b: Dictionary = _buildings[pos]
		if water_sim != null and water_sim.has_method("get_pressure_at"):
			b["has_water"] = water_sim.get_pressure_at(pos) > 1.0
		else:
			b["has_water"] = false
		if power_sim != null and power_sim.has_method("is_building_powered"):
			b["has_power"] = power_sim.is_building_powered(pos)
		else:
			b["has_power"] = false
		if b["population"] > 0:
			b["waste_accumulated"] = b["waste_accumulated"] + float(b["population"]) * 0.1


func _run_waste_collection() -> void:
	for collector in _waste_collectors:
		if collector["current_load"] >= collector["capacity"]:
			collector["current_load"] = 0.0
		var best_pos: Vector3i = Vector3i(-999, -999, -999)
		var best_waste: float = 0.0
		for pos in _buildings:
			var b: Dictionary = _buildings[pos]
			if b["waste_accumulated"] > best_waste:
				best_waste = b["waste_accumulated"]
				best_pos = pos
		if best_pos.x != -999 and best_waste > 1.0:
			var b: Dictionary = _buildings[best_pos]
			var collected: float = minf(best_waste, collector["capacity"] - collector["current_load"])
			b["waste_accumulated"] = b["waste_accumulated"] - collected
			collector["current_load"] = collector["current_load"] + collected
			b["has_waste_service"] = true
			b["last_service_tick"] = GameManager.tick_number
			building_serviced.emit(best_pos, "waste", collected)


func _update_population_and_satisfaction() -> void:
	for pos in _buildings:
		var b: Dictionary = _buildings[pos]
		var water_score: float = 1.0 if b["has_water"] else 0.0
		var power_score: float = 1.0 if b["has_power"] else 0.0
		var waste_score: float = 1.0 if b["has_waste_service"] else 0.0
		var waste_penalty: float = clampf(b["waste_accumulated"] / 20.0, 0.0, 1.0)
		b["satisfaction"] = (
			water_score * 30.0 +
			power_score * 25.0 +
			waste_score * 25.0 +
			(1.0 - waste_penalty) * 20.0
		)
		var max_pop: int = 8
		if b["satisfaction"] > 70.0 and b["population"] < max_pop:
			b["population"] = b["population"] + 1
		elif b["satisfaction"] < 30.0 and b["population"] > 0:
			b["population"] = b["population"] - 1
		elif b["population"] == 0 and b["satisfaction"] > 50.0:
			b["population"] = 1