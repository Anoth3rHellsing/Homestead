extends CanvasLayer

## HUDController — In-game heads-up display showing city stats,
## current build mode, selected block/prefab, and debug toggle.

var _stats_label: Label = null
var _mode_label: Label = null
var _crosshair: ColorRect = null
var _build_menu_panel: PanelContainer = null
var _debug_panel: PanelContainer = null
var _update_timer: float = 0.0


func _ready() -> void:
	layer = 10

	# Crosshair (simple colored rect)
	_crosshair = ColorRect.new()
	_crosshair.color = Color(0.91, 0.91, 0.878, 0.8)
	_crosshair.anchor_left = 0.5
	_crosshair.anchor_top = 0.5
	_crosshair.anchor_right = 0.5
	_crosshair.anchor_bottom = 0.5
	_crosshair.offset_left = -2
	_crosshair.offset_top = -2
	_crosshair.offset_right = 2
	_crosshair.offset_bottom = 2
	add_child(_crosshair)

	# Stats panel (top-left)
	var stats_panel := PanelContainer.new()
	stats_panel.anchor_left = 0.0
	stats_panel.anchor_top = 0.0
	stats_panel.offset_left = 10
	stats_panel.offset_top = 10
	stats_panel.offset_right = 340
	stats_panel.offset_bottom = 200
	var stats_style := StyleBoxFlat.new()
	stats_style.bg_color = Color(0.1, 0.08, 0.06, 0.85)
	stats_style.border_color = Color(0.804, 0.498, 0.196, 0.6)
	stats_style.set_border_width_all(2)
	stats_style.set_corner_radius_all(4)
	stats_panel.add_theme_stylebox_override("panel", stats_style)
	add_child(stats_panel)

	_stats_label = Label.new()
	_stats_label.text = "Loading..."
	_stats_label.add_theme_font_size_override("font_size", 14)
	_stats_label.add_theme_color_override("font_color", Color(0.91, 0.91, 0.878))
	stats_panel.add_child(_stats_label)

	# Mode indicator (bottom-center)
	_mode_label = Label.new()
	_mode_label.anchor_left = 0.5
	_mode_label.anchor_right = 0.5
	_mode_label.anchor_bottom = 1.0
	_mode_label.anchor_top = 1.0
	_mode_label.offset_left = -200
	_mode_label.offset_right = 200
	_mode_label.offset_top = -50
	_mode_label.offset_bottom = -10
	_mode_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_mode_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	_mode_label.add_theme_font_size_override("font_size", 16)
	_mode_label.add_theme_color_override("font_color", Color(0.804, 0.498, 0.196))
	_mode_label.text = "[B] Build Menu"
	add_child(_mode_label)

	# Build menu panel (hidden by default)
	_build_menu_panel = PanelContainer.new()
	_build_menu_panel.anchor_left = 0.0
	_build_menu_panel.anchor_top = 0.5
	_build_menu_panel.anchor_bottom = 1.0
	_build_menu_panel.offset_left = 10
	_build_menu_panel.offset_top = -220
	_build_menu_panel.offset_right = 280
	_build_menu_panel.offset_bottom = -60
	_build_menu_panel.visible = false
	var menu_style := StyleBoxFlat.new()
	menu_style.bg_color = Color(0.12, 0.1, 0.08, 0.92)
	menu_style.border_color = Color(0.722, 0.451, 0.2, 0.7)
	menu_style.set_border_width_all(2)
	menu_style.set_corner_radius_all(6)
	_build_menu_panel.add_theme_stylebox_override("panel", menu_style)
	add_child(_build_menu_panel)

	var menu_vbox := VBoxContainer.new()
	menu_vbox.add_theme_constant_override("separation", 4)
	_build_menu_panel.add_child(menu_vbox)

	var title := Label.new()
	title.text = "CONSTRUCTION MENU"
	title.add_theme_font_size_override("font_size", 16)
	title.add_theme_color_override("font_color", Color(0.804, 0.498, 0.196))
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	menu_vbox.add_child(title)

	var sep := HSeparator.new()
	menu_vbox.add_child(sep)

	var categories: Array = ["Residential", "Industrial", "Commercial", "Infrastructure", "Decorative", "Blocks"]
	for cat in categories:
		var btn := Button.new()
		btn.text = cat
		btn.add_theme_font_size_override("font_size", 13)
		btn.pressed.connect(_on_category_pressed.bind(cat))
		menu_vbox.add_child(btn)

	# Debug panel (top-right, hidden by default)
	_debug_panel = PanelContainer.new()
	_debug_panel.anchor_left = 1.0
	_debug_panel.anchor_top = 0.0
	_debug_panel.anchor_right = 1.0
	_debug_panel.offset_left = -360
	_debug_panel.offset_top = 10
	_debug_panel.offset_right = -10
	_debug_panel.offset_bottom = 320
	_debug_panel.visible = false
	var debug_style := StyleBoxFlat.new()
	debug_style.bg_color = Color(0.05, 0.05, 0.05, 0.9)
	debug_style.border_color = Color(0.3, 0.8, 0.3, 0.5)
	debug_style.set_border_width_all(1)
	_debug_panel.add_theme_stylebox_override("panel", debug_style)
	add_child(_debug_panel)

	var debug_label := Label.new()
	debug_label.name = "DebugLabel"
	debug_label.text = "Debug Info"
	debug_label.add_theme_font_size_override("font_size", 12)
	debug_label.add_theme_color_override("font_color", Color(0.3, 0.8, 0.3))
	_debug_panel.add_child(debug_label)


func _process(delta: float) -> void:
	_update_timer = _update_timer + delta
	if _update_timer >= 0.5:
		_update_timer = 0.0
		_update_stats()
	# Listen for debug toggle since signal may not be wired yet
	if Input.is_action_just_pressed("toggle_debug"):
		toggle_debug()
	# Listen for build menu toggle to sync UI
	if Input.is_action_just_pressed("toggle_build_menu"):
		var build_tool = get_node_or_null("/root/Main/Player/BuildTool")
		if build_tool and build_tool.has_signal("build_mode_changed"):
			pass  # handled via signal below


func _notification(what: int) -> void:
	if what == NOTIFICATION_READY:
		# Defer connection so children exist
		call_deferred("_connect_signals")


func _connect_signals() -> void:
	var build_tool = get_node_or_null("/root/Main/Player/BuildTool")
	if build_tool and build_tool.has_signal("build_mode_changed"):
		if not build_tool.build_mode_changed.is_connected(_on_build_mode_changed):
			build_tool.build_mode_changed.connect(_on_build_mode_changed)


func toggle_debug() -> void:
	if _debug_panel != null:
		_debug_panel.visible = not _debug_panel.visible
		if _debug_panel.visible:
			_update_debug_info()


func _update_stats() -> void:
	if _stats_label == null:
		return
	var stats: Dictionary = GameManager.get_city_stats()
	var pop: int = int(stats.get("population", 0))
	var water: float = float(stats.get("water_flow", 0.0))
	var power: float = float(stats.get("power_output", 0.0))
	var waste: float = float(stats.get("waste", 0.0))
	var sat: float = float(stats.get("satisfaction", 0.0))
	var tick: int = int(stats.get("tick", 0))
	_stats_label.text = (
		"HOMESTEAD CITY STATS\n" +
		"--------------------\n" +
		"Population: %d\n" % pop +
		"Water Flow: %.1f\n" % water +
		"Power Output: %.1f\n" % power +
		"Waste: %.1f\n" % waste +
		"Satisfaction: %.0f%%\n" % sat +
		"Tick: %d" % tick
	)


func _update_debug_info() -> void:
	var debug_label = _debug_panel.get_node("DebugLabel")
	if debug_label == null:
		return
	var lines: Array = []
	lines.append("=== DEBUG OVERLAY ===")
	var water_sim = GameManager.water_simulator
	if water_sim != null and water_sim.has_method("get_debug_data"):
		var wd: Dictionary = water_sim.get_debug_data()
		var wnodes: Array = wd.get("nodes", [])
		var wedges: Array = wd.get("edges", [])
		lines.append("Water Nodes: %d" % wnodes.size())
		lines.append("Water Edges: %d" % wedges.size())
		lines.append("Water Tick: %d" % int(wd.get("tick", 0)))
	var power_sim = GameManager.power_simulator
	if power_sim != null and power_sim.has_method("get_debug_data"):
		var pd: Dictionary = power_sim.get_debug_data()
		var pnodes: Array = pd.get("nodes", [])
		lines.append("Power Nodes: %d" % pnodes.size())
	var service_mgr = GameManager.service_manager
	if service_mgr != null and service_mgr.has_method("get_debug_data"):
		var sd: Dictionary = service_mgr.get_debug_data()
		var blds: Array = sd.get("buildings", [])
		lines.append("Buildings: %d" % blds.size())
		lines.append("Waste Collectors: %d" % int(sd.get("collectors", 0)))
	var player = get_node_or_null("/root/Main/Player")
	if player != null:
		lines.append("Player: (%.1f, %.1f, %.1f)" % [player.position.x, player.position.y, player.position.z])
	var result: String = ""
	for i in range(lines.size()):
		if i > 0:
			result = result + "\n"
		result = result + str(lines[i])
	debug_label.text = result


func _on_build_mode_changed(mode: String) -> void:
	if mode == "voxel":
		_mode_label.text = "VOXEL MODE | LMB: Place | RMB: Destroy"
		_build_menu_panel.visible = true
	elif mode == "prefab":
		_mode_label.text = "PREFAB MODE | LMB: Place | RMB: Cancel"
		_build_menu_panel.visible = true
	else:
		_mode_label.text = "[B] Build Menu | [F3] Debug"
		_build_menu_panel.visible = false


func _on_category_pressed(category: String) -> void:
	var build_tool = get_node_or_null("/root/Main/Player/BuildTool")
	if build_tool == null:
		return
	if category == "Blocks":
		build_tool.select_voxel(VoxelTypes.Type.BRASS_WALL)
	else:
		var prefabs: Array = PrefabRegistry.get_prefabs_by_category(category)
		if prefabs.size() > 0:
			build_tool.select_prefab(prefabs[0]["name"])