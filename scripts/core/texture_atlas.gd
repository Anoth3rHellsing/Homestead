extends Node
## TextureAtlas — Generates procedural steampunk textures at runtime.
## Creates a texture atlas with tiles for each voxel type.
## Autoloaded as "TextureAtlas"

var atlas_texture: ImageTexture = null
const ATLAS_SIZE := 256
const TILE_SIZE := 16
const TILES_PER_ROW := 16

func _ready() -> void:
	_generate_atlas()

func _generate_atlas() -> void:
	var img := Image.create(ATLAS_SIZE, ATLAS_SIZE, false, Image.FORMAT_RGBA8)
	img.fill(Color(0, 0, 0, 0))

	# Generate tile for each voxel type
	for type_val in range(26):
		var tx := type_val % TILES_PER_ROW
		var ty := type_val / TILES_PER_ROW
		var ox := tx * TILE_SIZE
		var oy := ty * TILE_SIZE
		_draw_tile(img, ox, oy, type_val)

	atlas_texture = ImageTexture.create_from_image(img)

func _draw_tile(img: Image, ox: int, oy: int, type_val: int) -> void:
	var base_color := VoxelTypes.get_color(type_val)

	match type_val:
		0: # AIR - transparent
			return
		1: # DIRT
			_draw_noise_tile(img, ox, oy, base_color, Color(0.35, 0.25, 0.15), 0.3)
		2: # STONE
			_draw_stone_tile(img, ox, oy, base_color)
		3: # BRASS_WALL
			_draw_brass_tile(img, ox, oy, base_color)
		4: # COPPER_PIPE
			_draw_pipe_tile(img, ox, oy, base_color)
		5: # IRON_BEAM
			_draw_iron_tile(img, ox, oy, base_color)
		6: # WOOD_PLANK
			_draw_wood_tile(img, ox, oy, base_color)
		7: # BOILER
			_draw_boiler_tile(img, ox, oy, base_color)
		8: # PUMP
			_draw_gear_tile(img, ox, oy, base_color, Color(0.7, 0.5, 0.2))
		9: # VALVE
			_draw_valve_tile(img, ox, oy, base_color)
		10: # FILTER
			_draw_filter_tile(img, ox, oy, base_color)
		11: # COAL_BLOCK
			_draw_coal_tile(img, ox, oy, base_color)
		12: # STEAM_VENT
			_draw_steam_tile(img, ox, oy, base_color)
		13: # WATER_SOURCE
			_draw_water_tile(img, ox, oy, base_color)
		14: # WASTE_OUTPUT
			_draw_waste_tile(img, ox, oy, base_color)
		15: # TREATMENT_PLANT
			_draw_treatment_tile(img, ox, oy, base_color)
		16: # RESERVOIR
			_draw_reservoir_tile(img, ox, oy, base_color)
		17: # GENERATOR
			_draw_generator_tile(img, ox, oy, base_color)
		18: # PIPE_COPPER
			_draw_pipe_tile(img, ox, oy, base_color)
		19: # PIPE_IRON
			_draw_pipe_tile(img, ox, oy, base_color)
		20: # GLASS
			_draw_glass_tile(img, ox, oy, base_color)
		21: # BRICK
			_draw_brick_tile(img, ox, oy, base_color)
		22: # ROOF_TILE
			_draw_roof_tile(img, ox, oy, base_color)
		23: # GEAR_DECORATIVE
			_draw_gear_tile(img, ox, oy, base_color, Color(0.9, 0.7, 0.3))
		24: # LAMP_GAS
			_draw_lamp_tile(img, ox, oy, base_color)
		25: # WORKBENCH
			_draw_workbench_tile(img, ox, oy, base_color)

func _set_pixel(img: Image, x: int, y: int, c: Color) -> void:
	if x >= 0 and x < ATLAS_SIZE and y >= 0 and y < ATLAS_SIZE:
		img.set_pixel(x, y, c)

func _lerp_color(a: Color, b: Color, t: float) -> Color:
	return Color(
		a.r + (b.r - a.r) * t,
		a.g + (b.g - a.g) * t,
		a.b + (b.b - a.b) * t,
		a.a + (b.a - a.a) * t
	)

func _pseudo_random(x: int, y: int) -> float:
	var n := x * 374761393 + y * 668265263
	n = (n ^ (n >> 13)) * 1274126177
	n = n ^ (n >> 16)
	return float((n & 0x7FFFFFFF) % 1000) / 1000.0

func _draw_noise_tile(img: Image, ox: int, oy: int, c1: Color, c2: Color, intensity: float) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var noise := _pseudo_random(ox + x, oy + y)
			var c := _lerp_color(c1, c2, noise * intensity)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_stone_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var noise := _pseudo_random(ox + x * 3, oy + y * 7)
			var crack := 0.0
			if (x + y * 3) % 7 == 0 or (x * 2 + y) % 11 == 0:
				crack = 0.15
			var c := _lerp_color(base, Color(0.3, 0.3, 0.28), noise * 0.2 + crack)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_brass_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var shine := 0.0
			if y == 0 or y == TILE_SIZE - 1:
				shine = 0.2
			elif x == 0 or x == TILE_SIZE - 1:
				shine = -0.1
			var noise := _pseudo_random(ox + x, oy + y) * 0.05
			var c := _lerp_color(base, Color(1, 0.85, 0.5), shine + noise)
			_set_pixel(img, ox + x, oy + y, c)
	# Rivets
	_set_pixel(img, ox + 2, oy + 2, Color(0.6, 0.4, 0.15))
	_set_pixel(img, ox + 13, oy + 2, Color(0.6, 0.4, 0.15))
	_set_pixel(img, ox + 2, oy + 13, Color(0.6, 0.4, 0.15))
	_set_pixel(img, ox + 13, oy + 13, Color(0.6, 0.4, 0.15))

func _draw_pipe_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var dist_from_center := abs(float(x) - 7.5) / 7.5
			var highlight := (1.0 - dist_from_center) * 0.3
			var c := _lerp_color(base, Color(1, 0.9, 0.7), highlight)
			if x < 2 or x > 13:
				c = _lerp_color(c, Color(0.2, 0.15, 0.1), 0.5)
			_set_pixel(img, ox + x, oy + y, c)
	# Flange lines
	for x in range(TILE_SIZE):
		_set_pixel(img, ox + x, oy + 3, _lerp_color(base, Color(0, 0, 0), 0.3))
		_set_pixel(img, ox + x, oy + 12, _lerp_color(base, Color(0, 0, 0), 0.3))

func _draw_iron_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var noise := _pseudo_random(ox + x * 5, oy + y * 3) * 0.1
			var rust := 0.0
			if _pseudo_random(ox + x, oy + y) > 0.85:
				rust = 0.2
			var c := _lerp_color(base, Color(0.4, 0.25, 0.1), rust)
			c = _lerp_color(c, Color(0.3, 0.3, 0.3), noise)
			_set_pixel(img, ox + x, oy + y, c)
	# I-beam pattern
	for y in range(TILE_SIZE):
		_set_pixel(img, ox + 7, oy + y, _lerp_color(base, Color(0, 0, 0), 0.2))
		_set_pixel(img, ox + 8, oy + y, _lerp_color(base, Color(0, 0, 0), 0.2))

func _draw_wood_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var grain := sin(float(y) * 1.5 + _pseudo_random(ox + x, oy) * 3.0) * 0.1
			var c := _lerp_color(base, Color(0.3, 0.2, 0.05), abs(grain))
			_set_pixel(img, ox + x, oy + y, c)
	# Plank gaps
	for x in range(TILE_SIZE):
		_set_pixel(img, ox + x, oy + 5, Color(0.15, 0.1, 0.05))
		_set_pixel(img, ox + x, oy + 11, Color(0.15, 0.1, 0.05))

func _draw_boiler_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var heat := _pseudo_random(ox + x * 2, oy + y * 2)
			var c := _lerp_color(base, Color(0.8, 0.2, 0.0), heat * 0.3)
			_set_pixel(img, ox + x, oy + y, c)
	# Pressure gauge circle
	for angle in range(360):
		var rad := float(angle) * PI / 180.0
		var px := int(7.5 + cos(rad) * 4.0)
		var py := int(7.5 + sin(rad) * 4.0)
		_set_pixel(img, ox + px, oy + py, Color(0.9, 0.8, 0.3))

func _draw_gear_tile(img: Image, ox: int, oy: int, base: Color, accent: Color) -> void:
	_fill_rect(img, ox, oy, TILE_SIZE, TILE_SIZE, _lerp_color(base, Color(0, 0, 0), 0.3))
	# Gear teeth
	for i in range(8):
		var angle := float(i) * PI / 4.0
		for r in range(5, 8):
			var px := int(7.5 + cos(angle) * float(r))
			var py := int(7.5 + sin(angle) * float(r))
			_set_pixel(img, ox + px, oy + py, accent)
	# Center hub
	for dy in range(-2, 3):
		for dx in range(-2, 3):
			if dx * dx + dy * dy <= 4:
				_set_pixel(img, ox + 7 + dx, oy + 7 + dy, accent)

func _draw_valve_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	_draw_pipe_tile(img, ox, oy, base)
	# Valve wheel
	for angle in range(360):
		var rad := float(angle) * PI / 180.0
		var px := int(7.5 + cos(rad) * 5.0)
		var py := int(7.5 + sin(rad) * 5.0)
		_set_pixel(img, ox + px, oy + py, Color(0.8, 0.2, 0.1))
	_set_pixel(img, ox + 7, oy + 7, Color(0.9, 0.8, 0.3))

func _draw_filter_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var mesh_pattern := 0.0
			if x % 3 == 0 or y % 3 == 0:
				mesh_pattern = 0.2
			var c := _lerp_color(base, Color(0.2, 0.3, 0.25), mesh_pattern)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_coal_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var noise := _pseudo_random(ox + x * 7, oy + y * 11)
			var c := _lerp_color(base, Color(0.2, 0.18, 0.2), noise * 0.3)
			if noise > 0.9:
				c = Color(0.8, 0.3, 0.0) # ember
			_set_pixel(img, ox + x, oy + y, c)

func _draw_steam_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var swirl := sin(float(x + y) * 0.8) * 0.15
			var c := _lerp_color(base, Color(0.7, 0.7, 0.65), swirl + 0.1)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_water_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var wave := sin(float(x) * 0.8 + float(y) * 0.3) * 0.1
			var c := _lerp_color(base, Color(0.5, 0.7, 0.85), wave + 0.15)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_waste_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var noise := _pseudo_random(ox + x * 3, oy + y * 5)
			var c := _lerp_color(base, Color(0.3, 0.25, 0.1), noise * 0.3)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_treatment_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	_fill_rect(img, ox, oy, TILE_SIZE, TILE_SIZE, base)
	# Tank outlines
	for x in range(TILE_SIZE):
		_set_pixel(img, ox + x, oy + 0, Color(0.2, 0.35, 0.3))
		_set_pixel(img, ox + x, oy + 15, Color(0.2, 0.35, 0.3))
	for y in range(TILE_SIZE):
		_set_pixel(img, ox + 0, oy + y, Color(0.2, 0.35, 0.3))
		_set_pixel(img, ox + 15, oy + y, Color(0.2, 0.35, 0.3))
	# Bubbles
	_set_pixel(img, ox + 4, oy + 5, Color(0.5, 0.7, 0.6))
	_set_pixel(img, ox + 10, oy + 8, Color(0.5, 0.7, 0.6))
	_set_pixel(img, ox + 7, oy + 11, Color(0.5, 0.7, 0.6))

func _draw_reservoir_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	_fill_rect(img, ox, oy, TILE_SIZE, TILE_SIZE, _lerp_color(base, Color(0, 0, 0), 0.2))
	# Water level
	for y in range(4, TILE_SIZE):
		for x in range(2, 14):
			var wave := sin(float(x) * 0.5) * 0.05
			var c := _lerp_color(Color(0.3, 0.5, 0.65), Color(0.4, 0.6, 0.75), wave + 0.5)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_generator_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	_fill_rect(img, ox, oy, TILE_SIZE, TILE_SIZE, base)
	# Coil pattern
	for y in range(TILE_SIZE):
		var coil_x := int(7.5 + sin(float(y) * 1.2) * 4.0)
		_set_pixel(img, ox + coil_x, oy + y, Color(0.8, 0.6, 0.2))
		_set_pixel(img, ox + coil_x + 1, oy + y, Color(0.8, 0.6, 0.2))
	# Lightning bolt
	_set_pixel(img, ox + 6, oy + 3, Color(1, 1, 0.5))
	_set_pixel(img, ox + 7, oy + 5, Color(1, 1, 0.5))
	_set_pixel(img, ox + 8, oy + 7, Color(1, 1, 0.5))
	_set_pixel(img, ox + 7, oy + 9, Color(1, 1, 0.5))

func _draw_glass_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var reflection := 0.0
			if x + y == 7 or x + y == 8:
				reflection = 0.3
			var c := _lerp_color(base, Color(1, 1, 1), reflection)
			c.a = 0.6
			_set_pixel(img, ox + x, oy + y, c)
	# Frame
	for i in range(TILE_SIZE):
		_set_pixel(img, ox + i, oy, Color(0.3, 0.25, 0.2))
		_set_pixel(img, ox + i, oy + 15, Color(0.3, 0.25, 0.2))
		_set_pixel(img, ox, oy + i, Color(0.3, 0.25, 0.2))
		_set_pixel(img, ox + 15, oy + i, Color(0.3, 0.25, 0.2))

func _draw_brick_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var row := y / 4
			var offset := 4 if row % 2 == 1 else 0
			var bx := (x + offset) % 8
			var mortar := 0.0
			if y % 4 == 0 or bx == 0:
				mortar = 0.4
			var noise := _pseudo_random(ox + x, oy + y) * 0.08
			var c := _lerp_color(base, Color(0.5, 0.45, 0.35), mortar + noise)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_roof_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var wave := float((x + y * 2) % 6) / 6.0
			var c := _lerp_color(base, _lerp_color(base, Color(0, 0, 0), 0.3), wave * 0.3)
			_set_pixel(img, ox + x, oy + y, c)

func _draw_lamp_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	_fill_rect(img, ox, oy, TILE_SIZE, TILE_SIZE, Color(0.15, 0.12, 0.1))
	# Lamp post
	for y in range(4, TILE_SIZE):
		_set_pixel(img, ox + 7, oy + y, Color(0.3, 0.25, 0.2))
		_set_pixel(img, ox + 8, oy + y, Color(0.3, 0.25, 0.2))
	# Glow
	for dy in range(-3, 4):
		for dx in range(-3, 4):
			var dist := float(dx * dx + dy * dy)
			if dist < 9:
				var glow := 1.0 - dist / 9.0
				var c := Color(1.0, 0.85, 0.4, glow * 0.8)
				_set_pixel(img, ox + 7 + dx, oy + 2 + dy, c)

func _draw_workbench_tile(img: Image, ox: int, oy: int, base: Color) -> void:
	_draw_wood_tile(img, ox, oy, base)
	# Tools on top
	_set_pixel(img, ox + 3, oy + 3, Color(0.5, 0.5, 0.5)) # hammer
	_set_pixel(img, ox + 4, oy + 3, Color(0.5, 0.5, 0.5))
	_set_pixel(img, ox + 10, oy + 4, Color(0.7, 0.5, 0.2)) # wrench
	_set_pixel(img, ox + 11, oy + 5, Color(0.7, 0.5, 0.2))

func _fill_rect(img: Image, ox: int, oy: int, w: int, h: int, c: Color) -> void:
	for y in range(h):
		for x in range(w):
			_set_pixel(img, ox + x, oy + y, c)

func get_uv_for_type(type_val: int) -> Vector2:
	var tx := float(type_val % TILES_PER_ROW) / float(TILES_PER_ROW)
	var ty := float(type_val / TILES_PER_ROW) / float(TILES_PER_ROW)
	return Vector2(tx, ty)