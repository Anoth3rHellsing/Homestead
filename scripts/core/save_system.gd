extends Node

## SaveSystem — Serializes and deserializes world state, buildings,
## and simulation data to/from JSON files.

const SAVE_DIR: String = "user://saves/"
const AUTO_SAVE_INTERVAL: float = 300.0

var _auto_save_timer: float = 0.0


func _ready() -> void:
	_ensure_save_dir()


func _process(delta: float) -> void:
	_auto_save_timer = _auto_save_timer + delta
	if _auto_save_timer >= AUTO_SAVE_INTERVAL:
		_auto_save_timer = 0.0
		save_game("autosave")


func save_game(slot_name: String) -> bool:
	var data: Dictionary = {
		"version": 1,
		"timestamp": Time.get_unix_time_from_system(),
		"game_state": {
			"tick_number": GameManager.tick_number,
			"time_scale": GameManager.time_scale,
			"total_population": GameManager.total_population,
			"city_satisfaction": GameManager.city_satisfaction,
		},
		"chunks": _serialize_chunks(),
		"buildings": _serialize_buildings(),
	}

	var json_string: String = JSON.stringify(data, "\t")
	var path: String = SAVE_DIR + slot_name + ".json"

	var file = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveSystem: Failed to open %s for writing" % path)
		return false

	file.store_string(json_string)
	file.close()
	print("SaveSystem: Game saved to %s" % path)
	return true


func load_game(slot_name: String) -> bool:
	var path: String = SAVE_DIR + slot_name + ".json"

	if not FileAccess.file_exists(path):
		push_error("SaveSystem: Save file not found: %s" % path)
		return false

	var file = FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("SaveSystem: Failed to open %s for reading" % path)
		return false

	var json_string: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		push_error("SaveSystem: Failed to parse JSON: %s" % json.get_error_message())
		return false

	var data: Dictionary = json.data

	if data.has("game_state"):
		var gs: Dictionary = data["game_state"]
		GameManager.tick_number = int(gs.get("tick_number", 0))
		GameManager.time_scale = float(gs.get("time_scale", 1.0))
		GameManager.total_population = int(gs.get("total_population", 0))
		GameManager.city_satisfaction = float(gs.get("city_satisfaction", 100.0))

	if data.has("chunks"):
		_deserialize_chunks(data["chunks"])

	if data.has("buildings"):
		_deserialize_buildings(data["buildings"])

	print("SaveSystem: Game loaded from %s" % path)
	return true


func get_save_slots() -> Array:
	var slots: Array = []
	var dir = DirAccess.open(SAVE_DIR)
	if dir == null:
		return slots

	dir.list_dir_begin()
	var file_name: String = dir.get_next()
	while file_name != "":
		if file_name.ends_with(".json"):
			slots.append(file_name.get_basename())
		file_name = dir.get_next()
	dir.list_dir_end()

	return slots


func delete_save(slot_name: String) -> bool:
	var path: String = SAVE_DIR + slot_name + ".json"
	if FileAccess.file_exists(path):
		var err = DirAccess.remove_absolute(path)
		return err == OK
	return false


func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)


func _serialize_chunks() -> Array:
	var chunks_data: Array = []
	var voxel_engine = GameManager.voxel_engine
	if voxel_engine == null:
		return chunks_data
	if voxel_engine.has_method("get_all_chunk_data"):
		return voxel_engine.get_all_chunk_data()
	return chunks_data


func _deserialize_chunks(chunks_data: Array) -> void:
	var voxel_engine = GameManager.voxel_engine
	if voxel_engine == null:
		return
	for chunk_data in chunks_data:
		if voxel_engine.has_method("load_chunk_from_data"):
			voxel_engine.load_chunk_from_data(chunk_data)


func _serialize_buildings() -> Array:
	var buildings_data: Array = []
	var service_mgr = GameManager.service_manager
	if service_mgr == null:
		return buildings_data
	if service_mgr.has_method("get_all_building_data"):
		return service_mgr.get_all_building_data()
	return buildings_data


func _deserialize_buildings(buildings_data: Array) -> void:
	var service_mgr = GameManager.service_manager
	if service_mgr == null:
		return
	for bdata in buildings_data:
		if service_mgr.has_method("load_building_from_data"):
			service_mgr.load_building_from_data(bdata)