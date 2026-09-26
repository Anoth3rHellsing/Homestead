extends Node
## PrefabRegistry — Singleton catalog of all available steampunk prefabs.
## Autoloaded as "PrefabRegistry"

signal prefab_registered(prefab_name: String)

var _prefabs: Dictionary = {}


func _ready() -> void:
	_register_default_prefabs()


func register_prefab(data: Dictionary) -> void:
	if data.has("name"):
		_prefabs[data["name"]] = data
		prefab_registered.emit(data["name"])


func get_prefab(prefab_name: String) -> Dictionary:
	if _prefabs.has(prefab_name):
		return _prefabs[prefab_name]
	return {}


func get_all_prefabs() -> Array:
	var result: Array = []
	for key in _prefabs:
		result.append(_prefabs[key])
	return result


func get_prefabs_by_category(category: String) -> Array:
	var result: Array = []
	for key in _prefabs:
		if _prefabs[key].get("category", "") == category:
			result.append(_prefabs[key])
	return result


func get_categories() -> Array:
	var cats: Dictionary = {}
	for key in _prefabs:
		var cat: String = _prefabs[key].get("category", "Uncategorized")
		cats[cat] = true
	var result: Array = []
	for c in cats:
		result.append(c)
	return result


func _register_default_prefabs() -> void:
	_register_worker_house()
	_register_brass_apartment()
	_register_mansion()
	_register_tenement()
	_register_steam_boiler()
	_register_foundry()
	_register_factory()
	_register_coal_mine()
	_register_market_stall()
	_register_shop()
	_register_tavern()
	_register_pump_station()
	_register_water_treatment()
	_register_reservoir()
	_register_steam_generator()
	_register_power_substation()
	_register_sewer_outlet()
	_register_gas_lamp()
	_register_gear_fountain()
	_register_clock_tower()
	_register_statue()
	_register_park_bench()


func _make_voxel_array(size: Vector3i, fill_type: int = 0) -> PackedByteArray:
	var data: PackedByteArray = PackedByteArray()
	data.resize(size.x * size.y * size.z)
	data.fill(fill_type)
	return data


func _set_in_array(arr: PackedByteArray, size: Vector3i, x: int, y: int, z: int, val: int) -> void:
	if x >= 0 and x < size.x and y >= 0 and y < size.y and z >= 0 and z < size.z:
		arr[x + y * size.x + z * size.x * size.y] = val


func _fill_box(arr: PackedByteArray, size: Vector3i, x1: int, y1: int, z1: int, x2: int, y2: int, z2: int, val: int) -> void:
	for x in range(x1, x2 + 1):
		for y in range(y1, y2 + 1):
			for z in range(z1, z2 + 1):
				_set_in_array(arr, size, x, y, z, val)


func _register_worker_house() -> void:
	var sz: Vector3i = Vector3i(5, 4, 5)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 4, 0, 4, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 1, 0, 4, 2, 0, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 4, 4, 2, 4, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 1, 0, 2, 3, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 4, 1, 1, 4, 2, 3, VoxelTypes.Type.BRICK)
	_set_in_array(v, sz, 2, 1, 0, VoxelTypes.Type.AIR)
	_set_in_array(v, sz, 2, 2, 0, VoxelTypes.Type.AIR)
	_fill_box(v, sz, 0, 3, 0, 4, 3, 4, VoxelTypes.Type.ROOF_TILE)
	register_prefab({
		"name": "Worker House",
		"category": "Residential",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "water_input"},
			{"pos": Vector3i(4, 0, 2), "type": "waste_output"},
			{"pos": Vector3i(2, 0, 4), "type": "power_input"},
		],
		"population_capacity": 4,
		"description": "Basic Victorian worker housing.",
	})


func _register_brass_apartment() -> void:
	var sz: Vector3i = Vector3i(6, 6, 5)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 5, 0, 4, VoxelTypes.Type.STONE)
	for floor_y in range(1, 5):
		_fill_box(v, sz, 0, floor_y, 0, 5, floor_y, 0, VoxelTypes.Type.BRASS_WALL)
		_fill_box(v, sz, 0, floor_y, 4, 5, floor_y, 4, VoxelTypes.Type.BRASS_WALL)
		_fill_box(v, sz, 0, floor_y, 1, 0, floor_y, 3, VoxelTypes.Type.BRASS_WALL)
		_fill_box(v, sz, 5, floor_y, 1, 5, floor_y, 3, VoxelTypes.Type.BRASS_WALL)
		_set_in_array(v, sz, 2, floor_y, 0, VoxelTypes.Type.GLASS)
		_set_in_array(v, sz, 3, floor_y, 0, VoxelTypes.Type.GLASS)
	var floor_levels: Array = [2, 4]
	for floor_y in floor_levels:
		_fill_box(v, sz, 1, floor_y, 1, 4, floor_y, 3, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 5, 0, 5, 5, 4, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 5, 2, VoxelTypes.Type.GEAR_DECORATIVE)
	_set_in_array(v, sz, 5, 5, 2, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Brass Apartment",
		"category": "Residential",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "water_input"},
			{"pos": Vector3i(5, 0, 2), "type": "waste_output"},
			{"pos": Vector3i(2, 0, 4), "type": "power_input"},
		],
		"population_capacity": 12,
		"description": "Multi-story brass-clad apartment.",
	})


func _register_mansion() -> void:
	var sz: Vector3i = Vector3i(8, 5, 7)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 7, 0, 6, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 7, 3, 0, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 0, 1, 6, 7, 3, 6, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 0, 1, 1, 0, 3, 5, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 7, 1, 1, 7, 3, 5, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 1, 1, 1, 6, 3, 5, VoxelTypes.Type.AIR)
	_fill_box(v, sz, 3, 1, 0, 4, 2, 0, VoxelTypes.Type.AIR)
	_set_in_array(v, sz, 2, 2, 0, VoxelTypes.Type.GLASS)
	_set_in_array(v, sz, 5, 2, 0, VoxelTypes.Type.GLASS)
	_fill_box(v, sz, 1, 2, 1, 6, 2, 5, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 4, 0, 7, 4, 6, VoxelTypes.Type.ROOF_TILE)
	_set_in_array(v, sz, 1, 4, 3, VoxelTypes.Type.GEAR_DECORATIVE)
	_set_in_array(v, sz, 6, 4, 3, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Victorian Mansion",
		"category": "Residential",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 3), "type": "water_input"},
			{"pos": Vector3i(7, 0, 3), "type": "waste_output"},
			{"pos": Vector3i(3, 0, 6), "type": "power_input"},
		],
		"population_capacity": 8,
		"description": "Luxurious Victorian mansion for wealthy citizens.",
	})


func _register_tenement() -> void:
	var sz: Vector3i = Vector3i(5, 7, 4)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 4, 0, 3, VoxelTypes.Type.STONE)
	for floor_y in range(1, 6):
		_fill_box(v, sz, 0, floor_y, 0, 4, floor_y, 0, VoxelTypes.Type.BRICK)
		_fill_box(v, sz, 0, floor_y, 3, 4, floor_y, 3, VoxelTypes.Type.BRICK)
		_fill_box(v, sz, 0, floor_y, 1, 0, floor_y, 2, VoxelTypes.Type.BRICK)
		_fill_box(v, sz, 4, floor_y, 1, 4, floor_y, 2, VoxelTypes.Type.BRICK)
		_set_in_array(v, sz, 2, floor_y, 0, VoxelTypes.Type.GLASS)
	var floor_levels: Array = [2, 4, 6]
	for floor_y in floor_levels:
		_fill_box(v, sz, 1, floor_y, 1, 3, floor_y, 2, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 6, 0, 4, 6, 3, VoxelTypes.Type.ROOF_TILE)
	register_prefab({
		"name": "Tenement Block",
		"category": "Residential",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "water_input"},
			{"pos": Vector3i(4, 0, 2), "type": "waste_output"},
			{"pos": Vector3i(2, 0, 3), "type": "power_input"},
		],
		"population_capacity": 20,
		"description": "High-density tenement housing.",
	})


func _register_steam_boiler() -> void:
	var sz: Vector3i = Vector3i(3, 3, 3)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 2, 0, 2, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 1, 0, 2, 2, 2, VoxelTypes.Type.BOILER)
	_set_in_array(v, sz, 0, 1, 1, VoxelTypes.Type.COPPER_PIPE)
	_set_in_array(v, sz, 2, 1, 1, VoxelTypes.Type.COPPER_PIPE)
	_set_in_array(v, sz, 1, 2, 1, VoxelTypes.Type.STEAM_VENT)
	register_prefab({
		"name": "Steam Boiler",
		"category": "Industrial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 1, 1), "type": "water_input"},
			{"pos": Vector3i(2, 1, 1), "type": "steam_output"},
			{"pos": Vector3i(1, 0, 0), "type": "coal_input"},
		],
		"steam_output": 10.0,
		"water_consumption": 2.0,
		"coal_consumption": 1.0,
		"description": "Burns coal to produce steam.",
	})


func _register_foundry() -> void:
	var sz: Vector3i = Vector3i(6, 4, 5)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 5, 0, 4, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 5, 3, 0, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 4, 5, 3, 4, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 1, 0, 3, 3, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 5, 1, 1, 5, 3, 3, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 2, 1, 0, 3, 2, 0, VoxelTypes.Type.AIR)
	_set_in_array(v, sz, 1, 1, 2, VoxelTypes.Type.WORKBENCH)
	_set_in_array(v, sz, 4, 1, 2, VoxelTypes.Type.WORKBENCH)
	_fill_box(v, sz, 0, 3, 0, 5, 3, 4, VoxelTypes.Type.IRON_BEAM)
	register_prefab({
		"name": "Foundry",
		"category": "Industrial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "steam_input"},
			{"pos": Vector3i(5, 0, 2), "type": "waste_output"},
			{"pos": Vector3i(2, 0, 4), "type": "power_input"},
		],
		"steam_consumption": 5.0,
		"worker_capacity": 8,
		"description": "Heavy industrial foundry.",
	})


func _register_factory() -> void:
	var sz: Vector3i = Vector3i(8, 5, 6)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 7, 0, 5, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 7, 4, 0, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 5, 7, 4, 5, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 1, 0, 4, 4, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 7, 1, 1, 7, 4, 4, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 1, 1, 1, 6, 4, 4, VoxelTypes.Type.AIR)
	_fill_box(v, sz, 3, 1, 0, 4, 3, 0, VoxelTypes.Type.AIR)
	_set_in_array(v, sz, 2, 1, 2, VoxelTypes.Type.WORKBENCH)
	_set_in_array(v, sz, 5, 1, 2, VoxelTypes.Type.WORKBENCH)
	_set_in_array(v, sz, 2, 1, 4, VoxelTypes.Type.WORKBENCH)
	_set_in_array(v, sz, 5, 1, 4, VoxelTypes.Type.WORKBENCH)
	_fill_box(v, sz, 0, 4, 0, 7, 4, 5, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 7, 4, 5, VoxelTypes.Type.STEAM_VENT)
	register_prefab({
		"name": "Factory",
		"category": "Industrial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 3), "type": "steam_input"},
			{"pos": Vector3i(7, 0, 3), "type": "waste_output"},
			{"pos": Vector3i(3, 0, 5), "type": "power_input"},
		],
		"steam_consumption": 12.0,
		"worker_capacity": 16,
		"description": "Large-scale manufacturing facility.",
	})


func _register_coal_mine() -> void:
	var sz: Vector3i = Vector3i(4, 4, 4)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 3, 0, 3, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 3, 3, 0, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 1, 3, 3, 3, 3, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 1, 1, 0, 3, 2, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 3, 1, 1, 3, 3, 2, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 1, 1, 1, 2, 3, 2, VoxelTypes.Type.COAL_BLOCK)
	_fill_box(v, sz, 0, 3, 0, 3, 3, 3, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 1, 3, 1, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Coal Mine",
		"category": "Industrial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "power_input"},
			{"pos": Vector3i(3, 0, 2), "type": "coal_output"},
		],
		"coal_output": 5.0,
		"worker_capacity": 6,
		"description": "Extracts coal from underground deposits.",
	})


func _register_market_stall() -> void:
	var sz: Vector3i = Vector3i(4, 3, 3)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 3, 0, 2, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 1, 0, 3, 1, 0, VoxelTypes.Type.WOOD_PLANK)
	_set_in_array(v, sz, 0, 1, 2, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 3, 1, 2, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 2, 2, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 3, 2, 2, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 2, 0, 3, 2, 2, VoxelTypes.Type.BRASS_WALL)
	register_prefab({
		"name": "Market Stall",
		"category": "Commercial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 1), "type": "power_input"},
		],
		"commerce_value": 5.0,
		"description": "Open-air market stall.",
	})


func _register_shop() -> void:
	var sz: Vector3i = Vector3i(5, 4, 4)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 4, 0, 3, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 1, 0, 4, 2, 0, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 0, 1, 3, 4, 2, 3, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 0, 1, 1, 0, 2, 2, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 4, 1, 1, 4, 2, 2, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 1, 1, 0, 3, 2, 0, VoxelTypes.Type.GLASS)
	_fill_box(v, sz, 1, 1, 1, 3, 2, 2, VoxelTypes.Type.AIR)
	_fill_box(v, sz, 0, 3, 0, 4, 3, 3, VoxelTypes.Type.ROOF_TILE)
	_set_in_array(v, sz, 2, 3, 0, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Shop",
		"category": "Commercial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "power_input"},
			{"pos": Vector3i(4, 0, 2), "type": "water_input"},
		],
		"commerce_value": 10.0,
		"description": "Retail shop with glass storefront.",
	})


func _register_tavern() -> void:
	var sz: Vector3i = Vector3i(6, 4, 5)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 5, 0, 4, VoxelTypes.Type.WOOD_PLANK)
	_fill_box(v, sz, 0, 1, 0, 5, 2, 0, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 4, 5, 2, 4, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 1, 0, 2, 3, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 5, 1, 1, 5, 2, 3, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 2, 1, 0, 3, 2, 0, VoxelTypes.Type.AIR)
	_set_in_array(v, sz, 1, 1, 2, VoxelTypes.Type.WORKBENCH)
	_set_in_array(v, sz, 4, 1, 2, VoxelTypes.Type.WORKBENCH)
	_fill_box(v, sz, 0, 3, 0, 5, 3, 4, VoxelTypes.Type.ROOF_TILE)
	_set_in_array(v, sz, 5, 2, 4, VoxelTypes.Type.LAMP_GAS)
	register_prefab({
		"name": "Tavern",
		"category": "Commercial",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 2), "type": "water_input"},
			{"pos": Vector3i(5, 0, 2), "type": "waste_output"},
			{"pos": Vector3i(2, 0, 4), "type": "power_input"},
		],
		"commerce_value": 8.0,
		"happiness_bonus": 3.0,
		"description": "Social gathering place. Boosts citizen happiness.",
	})


func _register_pump_station() -> void:
	var sz: Vector3i = Vector3i(4, 3, 4)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 3, 0, 3, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 1, 1, 1, 2, 1, 2, VoxelTypes.Type.PUMP)
	_fill_box(v, sz, 0, 1, 0, 3, 2, 0, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 0, 1, 3, 3, 2, 3, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 0, 1, 1, 0, 2, 2, VoxelTypes.Type.BRASS_WALL)
	_fill_box(v, sz, 3, 1, 1, 3, 2, 2, VoxelTypes.Type.BRASS_WALL)
	_set_in_array(v, sz, 0, 1, 1, VoxelTypes.Type.PIPE_COPPER)
	_set_in_array(v, sz, 3, 1, 2, VoxelTypes.Type.PIPE_COPPER)
	_fill_box(v, sz, 0, 2, 0, 3, 2, 3, VoxelTypes.Type.IRON_BEAM)
	register_prefab({
		"name": "Pump Station",
		"category": "Infrastructure",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 1, 1), "type": "water_input"},
			{"pos": Vector3i(3, 1, 2), "type": "water_output"},
			{"pos": Vector3i(1, 0, 0), "type": "steam_input"},
		],
		"pressure_added": 15.0,
		"flow_capacity": 20.0,
		"steam_consumption": 3.0,
		"description": "Pressurizes water network.",
	})


func _register_water_treatment() -> void:
	var sz: Vector3i = Vector3i(6, 3, 5)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 5, 0, 4, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 2, 2, 2, VoxelTypes.Type.TREATMENT_PLANT)
	_fill_box(v, sz, 3, 1, 0, 5, 2, 2, VoxelTypes.Type.TREATMENT_PLANT)
	_fill_box(v, sz, 0, 1, 3, 5, 1, 4, VoxelTypes.Type.FILTER)
	_set_in_array(v, sz, 0, 1, 2, VoxelTypes.Type.PIPE_IRON)
	_set_in_array(v, sz, 5, 1, 2, VoxelTypes.Type.PIPE_COPPER)
	_set_in_array(v, sz, 2, 2, 3, VoxelTypes.Type.GEAR_DECORATIVE)
	_set_in_array(v, sz, 3, 2, 3, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Water Treatment Plant",
		"category": "Infrastructure",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 1, 2), "type": "waste_water_input"},
			{"pos": Vector3i(5, 1, 2), "type": "clean_water_output"},
			{"pos": Vector3i(2, 0, 4), "type": "steam_input"},
		],
		"treatment_rate": 10.0,
		"steam_consumption": 4.0,
		"description": "Converts waste water to clean water.",
	})


func _register_reservoir() -> void:
	var sz: Vector3i = Vector3i(5, 4, 5)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 4, 3, 0, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 0, 4, 4, 3, 4, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 0, 1, 0, 3, 3, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 4, 0, 1, 4, 3, 3, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 0, 0, 4, 0, 4, VoxelTypes.Type.STONE)
	_set_in_array(v, sz, 0, 1, 2, VoxelTypes.Type.PIPE_COPPER)
	_set_in_array(v, sz, 4, 1, 2, VoxelTypes.Type.PIPE_COPPER)
	_fill_box(v, sz, 0, 3, 0, 4, 3, 4, VoxelTypes.Type.IRON_BEAM)
	register_prefab({
		"name": "Reservoir",
		"category": "Infrastructure",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 1, 2), "type": "water_input"},
			{"pos": Vector3i(4, 1, 2), "type": "water_output"},
		],
		"capacity": 100.0,
		"description": "Stores water buffer.",
	})


func _register_steam_generator() -> void:
	var sz: Vector3i = Vector3i(4, 4, 4)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 3, 0, 3, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 1, 1, 1, 2, 3, 2, VoxelTypes.Type.GENERATOR)
	_fill_box(v, sz, 0, 1, 0, 3, 3, 0, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 1, 3, 3, 3, 3, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 1, 1, VoxelTypes.Type.PIPE_IRON)
	_set_in_array(v, sz, 3, 2, 1, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Steam Generator",
		"category": "Infrastructure",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 1, 1), "type": "steam_input"},
			{"pos": Vector3i(3, 1, 1), "type": "power_output"},
		],
		"power_output": 15.0,
		"steam_consumption": 8.0,
		"description": "Converts steam to electrical power.",
	})


func _register_power_substation() -> void:
	var sz: Vector3i = Vector3i(3, 3, 3)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 2, 0, 2, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 2, 2, 0, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 1, 2, 2, 2, 2, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 0, 1, 1, 0, 2, 1, VoxelTypes.Type.IRON_BEAM)
	_fill_box(v, sz, 2, 1, 1, 2, 2, 1, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 1, 1, 1, VoxelTypes.Type.GENERATOR)
	_set_in_array(v, sz, 1, 2, 1, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Power Substation",
		"category": "Infrastructure",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 1, 1), "type": "power_input"},
			{"pos": Vector3i(2, 1, 1), "type": "power_output"},
		],
		"power_throughput": 20.0,
		"description": "Distributes power to nearby buildings.",
	})


func _register_sewer_outlet() -> void:
	var sz: Vector3i = Vector3i(3, 2, 3)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 2, 0, 2, VoxelTypes.Type.STONE)
	_set_in_array(v, sz, 1, 0, 1, VoxelTypes.Type.WASTE_OUTPUT)
	_set_in_array(v, sz, 0, 0, 1, VoxelTypes.Type.PIPE_IRON)
	_set_in_array(v, sz, 2, 0, 1, VoxelTypes.Type.PIPE_IRON)
	_fill_box(v, sz, 0, 1, 0, 2, 1, 2, VoxelTypes.Type.IRON_BEAM)
	register_prefab({
		"name": "Sewer Outlet",
		"category": "Infrastructure",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 1), "type": "waste_input"},
			{"pos": Vector3i(2, 0, 1), "type": "waste_output"},
		],
		"waste_capacity": 30.0,
		"description": "Collects and routes waste water.",
	})


func _register_gas_lamp() -> void:
	var sz: Vector3i = Vector3i(1, 3, 1)
	var v: PackedByteArray = _make_voxel_array(sz)
	_set_in_array(v, sz, 0, 0, 0, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 1, 0, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 2, 0, VoxelTypes.Type.LAMP_GAS)
	register_prefab({
		"name": "Gas Lamp",
		"category": "Decorative",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(0, 0, 0), "type": "power_input"},
		],
		"light_radius": 8.0,
		"description": "Victorian gas street lamp.",
	})


func _register_gear_fountain() -> void:
	var sz: Vector3i = Vector3i(3, 3, 3)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 2, 0, 2, VoxelTypes.Type.STONE)
	_set_in_array(v, sz, 1, 1, 1, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 1, 2, 1, VoxelTypes.Type.GEAR_DECORATIVE)
	_set_in_array(v, sz, 1, 0, 1, VoxelTypes.Type.PIPE_COPPER)
	register_prefab({
		"name": "Gear Fountain",
		"category": "Decorative",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(1, 0, 1), "type": "water_input"},
		],
		"happiness_bonus": 2.0,
		"description": "Decorative fountain with spinning gears.",
	})


func _register_clock_tower() -> void:
	var sz: Vector3i = Vector3i(3, 8, 3)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 2, 0, 2, VoxelTypes.Type.STONE)
	_fill_box(v, sz, 0, 1, 0, 2, 6, 0, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 2, 2, 6, 2, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 0, 1, 1, 0, 6, 1, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 2, 1, 1, 2, 6, 1, VoxelTypes.Type.BRICK)
	_fill_box(v, sz, 1, 1, 1, 1, 6, 1, VoxelTypes.Type.AIR)
	_set_in_array(v, sz, 1, 5, 0, VoxelTypes.Type.GLASS)
	_set_in_array(v, sz, 1, 6, 1, VoxelTypes.Type.GEAR_DECORATIVE)
	_fill_box(v, sz, 0, 7, 0, 2, 7, 2, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 1, 7, 1, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Clock Tower",
		"category": "Decorative",
		"size": sz,
		"voxels": v,
		"connection_points": [
			{"pos": Vector3i(1, 0, 1), "type": "power_input"},
		],
		"happiness_bonus": 5.0,
		"description": "Iconic clock tower. Major happiness boost.",
	})


func _register_statue() -> void:
	var sz: Vector3i = Vector3i(2, 4, 2)
	var v: PackedByteArray = _make_voxel_array(sz)
	_fill_box(v, sz, 0, 0, 0, 1, 0, 1, VoxelTypes.Type.STONE)
	_set_in_array(v, sz, 0, 1, 0, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 1, 1, 0, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 1, 1, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 1, 1, 1, VoxelTypes.Type.IRON_BEAM)
	_set_in_array(v, sz, 0, 2, 0, VoxelTypes.Type.BRASS_WALL)
	_set_in_array(v, sz, 1, 2, 0, VoxelTypes.Type.BRASS_WALL)
	_set_in_array(v, sz, 0, 3, 0, VoxelTypes.Type.GEAR_DECORATIVE)
	register_prefab({
		"name": "Bronze Statue",
		"category": "Decorative",
		"size": sz,
		"voxels": v,
		"connection_points": [],
		"happiness_bonus": 3.0,
		"description": "Commemorative bronze statue.",
	})


func _register_park_bench() -> void:
	var sz: Vector3i = Vector3i(2, 1, 1)
	var v: PackedByteArray = _make_voxel_array(sz)
	_set_in_array(v, sz, 0, 0, 0, VoxelTypes.Type.WOOD_PLANK)
	_set_in_array(v, sz, 1, 0, 0, VoxelTypes.Type.WOOD_PLANK)
	register_prefab({
		"name": "Park Bench",
		"category": "Decorative",
		"size": sz,
		"voxels": v,
		"connection_points": [],
		"happiness_bonus": 1.0,
		"description": "Simple wooden bench for parks.",
	})