# Changelog — Homestead: Steampunk Voxel City Builder

All notable changes to this project are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [0.1.0] — 2026-09-09 — "First Steam"

### Added

**Core Engine**
- Custom voxel engine with 16×16×16 chunk system
- Dynamic chunk loading/unloading based on player position (render distance: 3 chunks)
- Greedy-style face culling mesh generation with per-vertex coloring
- Concave collision shapes for solid voxels
- Chunk serialization/deserialization for save system

**Procedural World Generation**
- Fractal Brownian Motion (FBM) noise-based terrain generator
- 4 distinct biomes: Flatlands, Hills, River Valley, Industrial Zone
- Biome-specific surface materials (grass, stone, cobblestone, riverbed)
- Decorative surface details: coal deposits in hills, iron beams in industrial zones, gear ornaments
- Water bodies in river valleys at low elevations
- Height variation per biome (Flatlands 4–6, Hills 3–11, River Valley 2–6, Industrial 5–6)

**Voxel Type System**
- 26 unique voxel types with individual properties (solid, transparent, pipe-connectable, power consumer, water producer, steam emitter)
- Per-type color palette with steampunk brass/copper/iron aesthetic
- Procedural texture atlas generation (256×256, 16×16 tiles per type)
- Texture patterns: dirt noise, stone cracks, brass rivets, pipe flanges, wood grain, boiler gauges, gear teeth, brick offset, glass reflections, coal embers, water waves

**Player & Controls**
- First-person controller with mouse look and WASD movement
- Walk / Sprint / Fly movement modes
- Gravity and floor collision
- Interaction raycast for block placement and destruction
- Ghost preview mesh for build placement
- Mouse capture/release toggle (Esc)

**Construction System**
- Voxel placement mode (LMB to place, RMB to destroy)
- Prefab stamping mode for multi-block buildings
- Build menu with category filtering (Residential, Industrial, Commercial, Infrastructure, Decorative, Blocks)
- Snap-to-grid voxel alignment

**22 Steampunk Prefabs**
- *Residential (4):* Worker House, Brass Apartment, Victorian Mansion, Tenement Block
- *Industrial (4):* Steam Boiler, Foundry, Factory, Coal Mine
- *Commercial (3):* Market Stall, Shop, Tavern
- *Infrastructure (6):* Pump Station, Water Treatment Plant, Reservoir, Steam Generator, Power Substation, Sewer Outlet
- *Decorative (5):* Gas Lamp, Gear Fountain, Clock Tower, Bronze Statue, Park Bench
- Each prefab includes connection points for water/power/waste networks
- Population capacity, worker capacity, commerce value, and happiness bonuses per building

**Simulation Systems**
- Water simulator: pressure-based flow network with pipe connectivity graph
- Power simulator: steam-to-electricity conversion grid
- Service manager: waste collection, citizen satisfaction tracking
- Tick-based simulation with configurable time scale (0.1× – 10×)
- Independent tick intervals per system (water 0.5s, power 0.5s, buildings 1s, citizens 2s, services 5s)

**User Interface**
- In-game HUD with city stats panel (population, water flow, power output, waste, satisfaction, tick counter)
- Build mode indicator with contextual controls display
- Construction menu panel with category buttons
- Debug overlay (F3) showing water nodes/edges, power nodes, building count, player coordinates
- Crosshair reticle

**Save System**
- JSON-based world state serialization
- Auto-save every 5 minutes
- Manual save/load with named slots
- Chunk data and building state persistence

**Environment & Rendering**
- Directional sunlight with shadows
- ACES tone mapping
- Atmospheric fog
- Steampunk sky color palette
- Per-face brightness variation (ambient occlusion approximation)
- Grass-green tinting on exposed dirt surfaces
- Translucent blue water rendering

**Project Configuration**
- Godot 4.7.2 (Forward Plus renderer)
- 1920×1080 default viewport with canvas_items stretch mode
- Custom input map for all game actions
- Physics layer naming (World, Player, Buildings, Infrastructure, UI_Raycast)
- Windows Desktop export preset configured

### Known Issues
- Export templates not bundled — must be downloaded via Godot editor before building .exe
- Texture atlas generated but not yet applied to mesh UVs (vertex coloring used instead)
- Water simulation is structural only — no visual fluid animation yet
- Citizens are tracked numerically but not rendered as entities
- No audio system implemented yet
- Save system references voxel engine methods not yet fully implemented (`get_all_chunk_data`, `load_chunk_from_data`)