extends RefCounted
## Comprueba la lógica de celdas y radios del streamer (F1.3).


func test_sector_streamer_cells_and_radius() -> bool:
	var streamer: SectorStreamer = SectorStreamer.new()
	streamer.sector_size = 100.0
	streamer.load_radius = 1
	streamer.unload_radius = 2
	var center: SectorDefinition = _definition(&"centro", Vector2i(0, 0))
	var east: SectorDefinition = _definition(&"este", Vector2i(1, 0))
	var north: SectorDefinition = _definition(&"norte", Vector2i(0, 1))
	var far: SectorDefinition = _definition(&"lejos", Vector2i(0, 2))
	var farther: SectorDefinition = _definition(&"muy_lejos", Vector2i(3, 0))
	var always: SectorDefinition = _definition(&"siempre", Vector2i(10, 10))
	always.always_loaded = true
	var definitions: Array[SectorDefinition] = [center, east, north, far, farther, always]
	streamer.sectors = definitions
	streamer.rebuild_index()
	var cell: Vector2i = streamer.get_cell_for_position(Vector3(150.0, 0.0, 50.0))
	var ok: bool = cell == Vector2i(1, 0)
	var needed: Array[SectorDefinition] = streamer.get_needed_definitions(Vector2i(0, 0))
	ok = ok and needed.size() == 4
	ok = ok and needed.has(center) and needed.has(east) and needed.has(north)
	ok = ok and needed.has(always) and not needed.has(far) and not needed.has(farther)
	ok = ok and streamer.get_sector_distance(&"lejos", Vector2i(0, 0)) == 2
	ok = ok and streamer.get_sector_distance(&"muy_lejos", Vector2i(0, 0)) == 3
	ok = ok and streamer.get_sector_distance(&"no_existe", Vector2i(0, 0)) == 9999
	ok = ok and streamer.get_definition(&"centro") == center
	ok = ok and streamer.get_definition(&"no_existe") == null
	streamer.free()
	return ok


func test_sector_streamer_registration() -> bool:
	var streamer: SectorStreamer = SectorStreamer.new()
	var definition: SectorDefinition = _definition(&"nuevo", Vector2i(2, 1))
	streamer.register_definition(definition)
	streamer.register_definition(definition)
	var ok: bool = streamer.sectors.size() == 1
	ok = ok and streamer.get_definition(&"nuevo") == definition
	streamer.free()
	return ok


func _definition(id: StringName, cell: Vector2i) -> SectorDefinition:
	var definition: SectorDefinition = SectorDefinition.new()
	definition.id = id
	definition.grid_position = cell
	definition.scene_path = "res://tests/scenes/sectors/sector_a.tscn"
	return definition
