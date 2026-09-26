# Homestead — Steampunk Voxel City Builder

A Cities Skylines-inspired city builder with voxel-level construction, first-person exploration, advanced water simulation, and steampunk aesthetics. Built with Godot 4 and GDScript.

## Features

- **Voxel World**: Editable 16³ chunk-based terrain with greedy meshing and LOD
- **First-Person Controller**: Walk, run, fly through your city; build and destroy voxels in real-time
- **Construction System**: Prefab placement (12 steampunk buildings) + free-form voxel editing
- **Water Simulation**: Graph-based pipe network with pressure, flow, valves, pumps, treatment plants, and recycling loops
- **Power Network**: Steam generation and electrical distribution
- **City Services**: Waste collection, citizen satisfaction, population dynamics
- **Steampunk Aesthetic**: Brass/copper/iron palette, Victorian-industrial materials

## Project Structure

```
Homestead/
├── project.godot              # Godot 4 project config
├── scenes/main.tscn           # Root scene (world + player + sim + UI)
├── scripts/
│   ├── core/
│   │   ├── game_manager.gd    # Singleton: tick loop, global state
│   │   ├── voxel_engine.gd    # Chunk streaming, voxel access, mesh rebuilds
│   │   ├── chunk.gd           # 16³ voxel data + mesh generation
│   │   ├── voxel_types.gd     # Voxel type registry and properties
│   │   └── save_system.gd     # JSON serialization/deserialization
│   ├── player/
│   │   ├── fps_controller.gd  # FPS movement, camera, input handling
│   │   └── build_tool.gd      # Voxel/prefab placement, ghost preview
│   ├── simulation/
│   │   ├── water_simulator.gd # Pipe network, pressure, treatment, recycling
│   │   ├── power_simulator.gd # Steam/electric power distribution
│   │   └── service_manager.gd # Waste collection, citizen stats
│   ├── construction/
│   │   └── prefab_registry.gd # 12 steampunk prefabs with voxel data
│   └── ui/
│       └── hud_controller.gd  # Stats panel, build menu, debug overlay
└── icon.svg                   # Project icon
```

## Controls

| Key | Action |
|-----|--------|
| W/A/S/D | Move |
| Space | Jump |
| Shift | Sprint / Fly down |
| Ctrl+Space | Toggle fly mode |
| LMB | Place block/prefab |
| RMB | Destroy block |
| B | Toggle build menu |
| F3 | Toggle debug overlay |
| Esc | Release mouse cursor |

## Getting Started

1. Open the `Homestead` folder in Godot 4.3+
2. Press F5 to run
3. You'll spawn above procedurally generated terrain
4. Press B to open the build menu and start constructing

## Architecture Notes

- **Tick Loop**: Water/power at 2Hz, buildings at 1Hz, citizens at 0.5Hz, services at 0.2Hz
- **Chunks**: 16×16×16 voxels, render distance 8 chunks, max 4 mesh rebuilds/frame
- **Water Sim**: BFS-connected graph with pressure propagation, friction loss, height-based gravity assist
- **Prefabs**: Stored as PackedByteArray voxel arrays with connection point metadata
- **Save System**: JSON serialization to `user://saves/`, auto-save every 5 minutes

## Color Palette

| Element | Hex |
|---------|-----|
| Brass | `#CD7F32` |
| Copper | `#B87333` |
| Dark Iron | `#2C2C2C` |
| Aged Wood | `#8B6914` |
| Steam | `#E8E8E0` |
| Patina | `#4A766E` |
| Clean Water | `#5B8FA8` |
| Waste Water | `#6B5B3A` |