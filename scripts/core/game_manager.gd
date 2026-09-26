extends Node

## GameManager — Global singleton that orchestrates all simulation systems.
## Autoloaded as "GameManager"

signal simulation_tick(tick_number: int)
signal water_tick()
signal power_tick()
signal building_tick()
signal citizen_tick()
signal service_tick()

const WATER_TICK_INTERVAL: float = 0.5
const POWER_TICK_INTERVAL: float = 0.5
const BUILDING_TICK_INTERVAL: float = 1.0
const CITIZEN_TICK_INTERVAL: float = 2.0
const SERVICE_TICK_INTERVAL: float = 5.0

var _water_accumulator: float = 0.0
var _power_accumulator: float = 0.0
var _building_accumulator: float = 0.0
var _citizen_accumulator: float = 0.0
var _service_accumulator: float = 0.0

var tick_number: int = 0
var is_paused: bool = false
var time_scale: float = 1.0

var total_population: int = 0
var total_water_flow: float = 0.0
var total_power_output: float = 0.0
var total_waste_generated: float = 0.0
var city_satisfaction: float = 0.0

var voxel_engine: Node = null
var water_simulator: Node = null
var power_simulator: Node = null
var service_manager: Node = null
var citizen_sim: Node = null


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func _process(delta: float) -> void:
	if is_paused:
		return

	var scaled_delta: float = delta * time_scale

	_water_accumulator = _water_accumulator + scaled_delta
	_power_accumulator = _power_accumulator + scaled_delta
	_building_accumulator = _building_accumulator + scaled_delta
	_citizen_accumulator = _citizen_accumulator + scaled_delta
	_service_accumulator = _service_accumulator + scaled_delta

	if _water_accumulator >= WATER_TICK_INTERVAL:
		_water_accumulator = _water_accumulator - WATER_TICK_INTERVAL
		water_tick.emit()

	if _power_accumulator >= POWER_TICK_INTERVAL:
		_power_accumulator = _power_accumulator - POWER_TICK_INTERVAL
		power_tick.emit()

	if _building_accumulator >= BUILDING_TICK_INTERVAL:
		_building_accumulator = _building_accumulator - BUILDING_TICK_INTERVAL
		building_tick.emit()

	if _citizen_accumulator >= CITIZEN_TICK_INTERVAL:
		_citizen_accumulator = _citizen_accumulator - CITIZEN_TICK_INTERVAL
		citizen_tick.emit()

	if _service_accumulator >= SERVICE_TICK_INTERVAL:
		_service_accumulator = _service_accumulator - SERVICE_TICK_INTERVAL
		service_tick.emit()

	tick_number = tick_number + 1
	simulation_tick.emit(tick_number)


func set_pause(paused: bool) -> void:
	is_paused = paused


func set_time_scale(scale_val: float) -> void:
	time_scale = clampf(scale_val, 0.1, 10.0)


func register_voxel_engine(engine: Node) -> void:
	voxel_engine = engine


func register_water_simulator(sim: Node) -> void:
	water_simulator = sim


func register_power_simulator(sim: Node) -> void:
	power_simulator = sim


func register_service_manager(mgr: Node) -> void:
	service_manager = mgr


func register_citizen_sim(sim: Node) -> void:
	citizen_sim = sim


func get_city_stats() -> Dictionary:
	return {
		"population": total_population,
		"water_flow": total_water_flow,
		"power_output": total_power_output,
		"waste": total_waste_generated,
		"satisfaction": city_satisfaction,
		"tick": tick_number,
	}