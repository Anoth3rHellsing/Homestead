# Homestead - Steampunk Voxel City Builder

## Project Location
**Current path:** `D:\ClaudeCodeD\Homestead`
**Previous path:** `C:\Users\nicol\Documents\ClaudeCode\Homestead` (moved to save C: drive space)

## Godot Executable
`C:\Users\nicol\Documents\ClaudeCode\Homestead\Godot_v4.7.2-stable_win64_console.exe`
(Note: The Godot binary itself was NOT moved — it remains in the original C: location)

## How to Export as .exe
1. Open Godot editor and import the project from `D:\ClaudeCodeD\Homestead\project.godot`
2. Install export templates: Editor → Manage Export Templates → Download and Install
3. Go to Project → Export → select "Windows Desktop" preset → Export Project
4. The .exe will be generated at `D:\ClaudeCodeD\Homestead\build\Homestead.exe`

## Project Structure
```
D:\ClaudeCodeD\Homestead\
├── project.godot              # Main project config
├── export_presets.cfg         # Export configuration (Windows Desktop)
├── scenes/
│   └── main.tscn              # Main scene
├── scripts/
│   ├── core/
│   │   ├── chunk.gd           # Voxel chunk meshing + terrain gen
│   │   ├── game_manager.gd    # Global simulation orchestrator
│   │   ├── save_system.gd     # Save/load JSON
│   │   ├── terrain_generator.gd  # Procedural biomes (FBM noise)
│   │   ├── texture_atlas.gd   # Procedural texture generation
│   │   ├── voxel_engine.gd    # Chunk loading/unloading
│   │   └── voxel_types.gd     # Voxel type registry (autoload)
│   ├── construction/
│   │   └── prefab_registry.gd # 22 steampunk prefabs (autoload)
│   ├── player/
│   │   ├── build_tool.gd      # Voxel placement/destruction
│   │   └── fps_controller.gd  # First-person movement
│   ├── simulation/
│   │   ├── power_simulator.gd # Power grid simulation
│   │   ├── service_manager.gd # Waste collection, satisfaction
│   │   └── water_simulator.gd # Water pressure/flow
│   └── ui/
│       └── hud_controller.gd  # In-game HUD
└── build/                     # Export output folder (create before export)
```

## Autoloads (in project.godot)
- GameManager → scripts/core/game_manager.gd
- VoxelTypes → scripts/core/voxel_types.gd
- PrefabRegistry → scripts/construction/prefab_registry.gd
- TerrainGenerator → scripts/core/terrain_generator.gd

## Controls
- WASD — Move
- Space — Jump
- Shift — Sprint
- Ctrl+Space — Toggle fly mode
- B — Build menu
- LMB — Place block/prefab
- RMB — Destroy block
- F3 — Debug overlay
- Esc — Release cursor

## Biomes
- Flatlands (green grass, height 4-6) — best for building
- Hills (grey stone, height 3-11) — coal deposits
- River Valley (blue water, height 2-6) — water sources
- Industrial Zone (cobblestone, height 5-6) — iron beams, gears

## Prefabs (22 total)
- Residential: Worker House, Brass Apartment, Victorian Mansion, Tenement Block
- Industrial: Steam Boiler, Foundry, Factory, Coal Mine
- Commercial: Market Stall, Shop, Tavern
- Infrastructure: Pump Station, Water Treatment, Reservoir, Steam Generator, Power Substation, Sewer Outlet
- Decorative: Gas Lamp, Gear Fountain, Clock Tower, Bronze Statue, Park Bench