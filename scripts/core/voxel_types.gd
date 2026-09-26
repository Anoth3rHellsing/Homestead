extends Node

## VoxelTypes — Singleton registry of all voxel types and their properties.
## Autoloaded as "VoxelTypes"

enum Type {
	AIR = 0,
	DIRT = 1,
	STONE = 2,
	BRASS_WALL = 3,
	COPPER_PIPE = 4,
	IRON_BEAM = 5,
	WOOD_PLANK = 6,
	BOILER = 7,
	PUMP = 8,
	VALVE = 9,
	FILTER = 10,
	COAL_BLOCK = 11,
	STEAM_VENT = 12,
	WATER_SOURCE = 13,
	WASTE_OUTPUT = 14,
	TREATMENT_PLANT = 15,
	RESERVOIR = 16,
	GENERATOR = 17,
	PIPE_COPPER = 18,
	PIPE_IRON = 19,
	GLASS = 20,
	BRICK = 21,
	ROOF_TILE = 22,
	GEAR_DECORATIVE = 23,
	LAMP_GAS = 24,
	WORKBENCH = 25,
}

var PROPERTIES: Dictionary = {}


func _ready() -> void:
	_init_properties()


func _init_properties() -> void:
	PROPERTIES[Type.AIR] = {"solid": false, "transparent": true, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Air", "color": Color(0, 0, 0, 0)}
	PROPERTIES[Type.DIRT] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Dirt", "color": Color(0.45, 0.35, 0.22)}
	PROPERTIES[Type.STONE] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Stone", "color": Color(0.5, 0.5, 0.48)}
	PROPERTIES[Type.BRASS_WALL] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Brass Wall", "color": Color(0.804, 0.498, 0.196)}
	PROPERTIES[Type.COPPER_PIPE] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Copper Pipe", "color": Color(0.722, 0.451, 0.2)}
	PROPERTIES[Type.IRON_BEAM] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Iron Beam", "color": Color(0.173, 0.173, 0.173)}
	PROPERTIES[Type.WOOD_PLANK] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Wood Plank", "color": Color(0.545, 0.412, 0.078)}
	PROPERTIES[Type.BOILER] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": true, "name": "Boiler", "color": Color(0.6, 0.3, 0.15)}
	PROPERTIES[Type.PUMP] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": true, "water_producer": false, "steam_emitter": false, "name": "Pump", "color": Color(0.55, 0.4, 0.25)}
	PROPERTIES[Type.VALVE] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Valve", "color": Color(0.7, 0.5, 0.2)}
	PROPERTIES[Type.FILTER] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": true, "water_producer": false, "steam_emitter": false, "name": "Filter", "color": Color(0.4, 0.55, 0.5)}
	PROPERTIES[Type.COAL_BLOCK] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Coal Block", "color": Color(0.1, 0.1, 0.12)}
	PROPERTIES[Type.STEAM_VENT] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": true, "name": "Steam Vent", "color": Color(0.91, 0.91, 0.878)}
	PROPERTIES[Type.WATER_SOURCE] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": true, "steam_emitter": false, "name": "Water Source", "color": Color(0.357, 0.561, 0.659)}
	PROPERTIES[Type.WASTE_OUTPUT] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Waste Output", "color": Color(0.42, 0.357, 0.227)}
	PROPERTIES[Type.TREATMENT_PLANT] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": true, "water_producer": false, "steam_emitter": false, "name": "Treatment Plant", "color": Color(0.29, 0.463, 0.431)}
	PROPERTIES[Type.RESERVOIR] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Reservoir", "color": Color(0.3, 0.45, 0.55)}
	PROPERTIES[Type.GENERATOR] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": true, "name": "Steam Generator", "color": Color(0.65, 0.35, 0.15)}
	PROPERTIES[Type.PIPE_COPPER] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Copper Pipe Segment", "color": Color(0.722, 0.451, 0.2)}
	PROPERTIES[Type.PIPE_IRON] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Iron Pipe Segment", "color": Color(0.35, 0.35, 0.35)}
	PROPERTIES[Type.GLASS] = {"solid": true, "transparent": true, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Glass", "color": Color(0.7, 0.85, 0.9, 0.6)}
	PROPERTIES[Type.BRICK] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Brick", "color": Color(0.6, 0.3, 0.2)}
	PROPERTIES[Type.ROOF_TILE] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Roof Tile", "color": Color(0.4, 0.25, 0.2)}
	PROPERTIES[Type.GEAR_DECORATIVE] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Decorative Gear", "color": Color(0.75, 0.55, 0.2)}
	PROPERTIES[Type.LAMP_GAS] = {"solid": true, "transparent": false, "connects_pipe": true, "power_consumer": true, "water_producer": false, "steam_emitter": false, "name": "Gas Lamp", "color": Color(0.85, 0.75, 0.4)}
	PROPERTIES[Type.WORKBENCH] = {"solid": true, "transparent": false, "connects_pipe": false, "power_consumer": false, "water_producer": false, "steam_emitter": false, "name": "Workbench", "color": Color(0.5, 0.38, 0.2)}


func is_solid(type_val: int) -> bool:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["solid"]
	return false


func is_transparent(type_val: int) -> bool:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["transparent"]
	return true


func connects_to_pipe(type_val: int) -> bool:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["connects_pipe"]
	return false


func is_power_consumer(type_val: int) -> bool:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["power_consumer"]
	return false


func is_water_producer(type_val: int) -> bool:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["water_producer"]
	return false


func is_steam_emitter(type_val: int) -> bool:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["steam_emitter"]
	return false


func get_type_name(type_val: int) -> String:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["name"]
	return "Unknown"


func get_color(type_val: int) -> Color:
	if PROPERTIES.has(type_val):
		return PROPERTIES[type_val]["color"]
	return Color.MAGENTA


func get_all_buildable() -> Array:
	var result: Array = []
	for key in PROPERTIES:
		if key != Type.AIR:
			result.append(key)
	return result


func get_pipe_connectable() -> Array:
	var result: Array = []
	for key in PROPERTIES:
		if PROPERTIES[key]["connects_pipe"]:
			result.append(key)
	return result