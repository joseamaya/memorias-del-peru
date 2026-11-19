extends SceneTree
## Comprueba la carga y descarga asíncrona de sectores con escenas reales.
##
## El sector `a` está en la celda (0,0), `b` en (1,0) y `c` siempre cargado.
## Con `load_radius = 0` y `unload_radius = 1`, al moverse a la celda 1 se carga
## `b` y `a` sigue; al saltar a la celda 3 se descargan ambos y `c` permanece.

const SECTOR_A: String = "res://tests/scenes/sectors/sector_a.tscn"
const SECTOR_B: String = "res://tests/scenes/sectors/sector_b.tscn"
const SECTOR_C: String = "res://tests/scenes/sectors/sector_c.tscn"
const TIMEOUT_SECONDS: float = 5.0


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var stage: Node3D = Node3D.new()
	root.add_child(stage)
	var target: Node3D = Node3D.new()
	stage.add_child(target)
	var streamer: SectorStreamer = SectorStreamer.new()
	streamer.sector_size = 256.0
	streamer.load_radius = 0
	streamer.unload_radius = 1
	streamer.update_interval = 0.0
	streamer.target = target
	var definitions: Array[SectorDefinition] = [
		_definition(&"a", Vector2i(0, 0), SECTOR_A),
		_definition(&"b", Vector2i(1, 0), SECTOR_B),
		_definition(&"c", Vector2i(10, 10), SECTOR_C),
	]
	definitions[2].always_loaded = true
	streamer.sectors = definitions
	stage.add_child(streamer)
	var ok: bool = await _wait_loaded(streamer, &"a")
	if ok:
		ok = await _wait_loaded(streamer, &"c")
	ok = ok and not streamer.is_loaded(&"b")
	target.global_position = Vector3(300.0, 0.0, 0.0)
	if ok:
		ok = await _wait_loaded(streamer, &"b")
	ok = ok and streamer.is_loaded(&"a")
	target.global_position = Vector3(768.0, 0.0, 0.0)
	if ok:
		ok = await _wait_unloaded(streamer, &"a")
	if ok:
		ok = await _wait_unloaded(streamer, &"b")
	ok = ok and streamer.is_loaded(&"c")
	if ok:
		print("SECTOR_STREAMING_OK")
	else:
		printerr("SECTOR_STREAMING_FAIL")
	stage.queue_free()
	await process_frame
	quit(0 if ok else 1)


func _definition(id: StringName, cell: Vector2i, scene_path: String) -> SectorDefinition:
	var definition: SectorDefinition = SectorDefinition.new()
	definition.id = id
	definition.grid_position = cell
	definition.scene_path = scene_path
	return definition


func _wait_loaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if streamer.is_loaded(id):
			return true
		await process_frame
	return false


func _wait_unloaded(streamer: SectorStreamer, id: StringName) -> bool:
	var deadline: int = Time.get_ticks_msec() + int(TIMEOUT_SECONDS * 1000.0)
	while Time.get_ticks_msec() < deadline:
		if not streamer.is_loaded(id):
			return true
		await process_frame
	return false
