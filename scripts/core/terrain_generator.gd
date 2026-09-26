extends Node
## TerrainGenerator — Procedural terrain generation with biomes,
## rivers, hills, and flat areas for building.

const CHUNK_SIZE := 16

# Biome types
enum Biome { FLATLANDS, HILLS, RIVER_VALLEY, INDUSTRIAL_ZONE }

# Simple noise function (value noise with interpolation)
func _hash(x: int, y: int) -> float:
	var n := x * 374761393 + y * 668265263
	n = (n ^ (n >> 13)) * 1274126177
	n = n ^ (n >> 16)
	return float((n & 0x7FFFFFFF) % 10000) / 10000.0

func _smooth_noise(x: float, y: float) -> float:
	var ix := int(floor(x))
	var iy := int(floor(y))
	var fx := x - float(ix)
	var fy := y - float(iy)

	# Smoothstep
	fx = fx * fx * (3.0 - 2.0 * fx)
	fy = fy * fy * (3.0 - 2.0 * fy)

	var v00 := _hash(ix, iy)
	var v10 := _hash(ix + 1, iy)
	var v01 := _hash(ix, iy + 1)
	var v11 := _hash(ix + 1, iy + 1)

	var i0 := v00 + (v10 - v00) * fx
	var i1 := v01 + (v11 - v01) * fx
	return i0 + (i1 - i0) * fy

func _fbm(x: float, y: float, octaves: int = 4) -> float:
	var value := 0.0
	var amplitude := 1.0
	var frequency := 1.0
	var max_value := 0.0
	for i in range(octaves):
		value += _smooth_noise(x * frequency, y * frequency) * amplitude
		max_value += amplitude
		amplitude *= 0.5
		frequency *= 2.0
	return value / max_value

func get_biome_at(world_x: int, world_z: int) -> int:
	var biome_noise := _fbm(float(world_x) * 0.005, float(world_z) * 0.005, 2)
	if biome_noise < 0.3:
		return Biome.FLATLANDS
	elif biome_noise < 0.55:
		return Biome.HILLS
	elif biome_noise < 0.7:
		return Biome.RIVER_VALLEY
	else:
		return Biome.INDUSTRIAL_ZONE

func get_height_at(world_x: int, world_z: int) -> int:
	var biome := get_biome_at(world_x, world_z)
	var base_height := 4

	match biome:
		Biome.FLATLANDS:
			var n := _fbm(float(world_x) * 0.02, float(world_z) * 0.02, 3)
			base_height = 4 + int(n * 2.0)
		Biome.HILLS:
			var n := _fbm(float(world_x) * 0.03, float(world_z) * 0.03, 4)
			base_height = 3 + int(n * 8.0)
		Biome.RIVER_VALLEY:
			var river: float = _fbm(float(world_x) * 0.01, float(world_z) * 0.04, 2)
			var river_dist: float = absf(river - 0.5) * 2.0
			base_height = 2 + int(river_dist * 4.0)
		Biome.INDUSTRIAL_ZONE:
			var n := _fbm(float(world_x) * 0.015, float(world_z) * 0.015, 2)
			base_height = 5 + int(n * 1.0)

	return clampi(base_height, 1, 14)

func get_voxel_at(world_x: int, world_y: int, world_z: int) -> int:
	var height := get_height_at(world_x, world_z)
	var biome := get_biome_at(world_x, world_z)

	if world_y > height:
		# Check for water in river valleys
		if biome == Biome.RIVER_VALLEY and world_y <= 3:
			return 13 # WATER_SOURCE
		return 0 # AIR

	if world_y == height:
		# Surface layer
		match biome:
			Biome.FLATLANDS:
				return 1 # DIRT (grass-like)
			Biome.HILLS:
				return 2 # STONE
			Biome.RIVER_VALLEY:
				if world_y <= 3:
					return 1 # DIRT (riverbed)
				return 1 # DIRT
			Biome.INDUSTRIAL_ZONE:
				return 2 # STONE (cobblestone-like)

	if world_y >= height - 2:
		return 1 # DIRT sublayer

	return 2 # STONE deep layer

func generate_chunk_data(chunk_pos: Vector3i) -> PackedByteArray:
	var data := PackedByteArray()
	data.resize(CHUNK_SIZE * CHUNK_SIZE * CHUNK_SIZE)

	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var world_x := chunk_pos.x * CHUNK_SIZE + x
			var world_z := chunk_pos.z * CHUNK_SIZE + z
			var height := get_height_at(world_x, world_z)
			var biome := get_biome_at(world_x, world_z)

			for y in range(CHUNK_SIZE):
				var world_y := chunk_pos.y * CHUNK_SIZE + y
				var idx := x + y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE

				if world_y > height:
					if biome == Biome.RIVER_VALLEY and world_y <= 3:
						data[idx] = 13 # Water
					else:
						data[idx] = 0 # Air
				elif world_y == height:
					match biome:
						Biome.FLATLANDS:
							data[idx] = 1
						Biome.HILLS:
							data[idx] = 2
						Biome.RIVER_VALLEY:
							data[idx] = 1
						Biome.INDUSTRIAL_ZONE:
							data[idx] = 2
				elif world_y >= height - 2:
					data[idx] = 1
				else:
					data[idx] = 2

	# Add some decorative elements on surface
	_add_surface_details(data, chunk_pos)

	return data

func _add_surface_details(data: PackedByteArray, chunk_pos: Vector3i) -> void:
	for x in range(CHUNK_SIZE):
		for z in range(CHUNK_SIZE):
			var world_x := chunk_pos.x * CHUNK_SIZE + x
			var world_z := chunk_pos.z * CHUNK_SIZE + z
			var height := get_height_at(world_x, world_z)
			var local_y := height - chunk_pos.y * CHUNK_SIZE

			if local_y < 0 or local_y >= CHUNK_SIZE - 1:
				continue

			var detail_noise := _hash(world_x * 7, world_z * 13)

			# Occasional coal deposits in hills
			var biome := get_biome_at(world_x, world_z)
			if biome == Biome.HILLS and detail_noise > 0.92:
				var idx := x + local_y * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE
				if idx >= 0 and idx < data.size():
					data[idx] = 11 # COAL_BLOCK

			# Occasional iron beams sticking out in industrial zones
			if biome == Biome.INDUSTRIAL_ZONE and detail_noise > 0.95:
				var idx := x + (local_y + 1) * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE
				if idx >= 0 and idx < data.size():
					data[idx] = 5 # IRON_BEAM

			# Rare gear decorations
			if detail_noise > 0.98:
				var idx := x + (local_y + 1) * CHUNK_SIZE + z * CHUNK_SIZE * CHUNK_SIZE
				if idx >= 0 and idx < data.size():
					data[idx] = 23 # GEAR_DECORATIVE