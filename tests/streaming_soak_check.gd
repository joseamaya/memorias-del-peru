extends SceneTree
## Mide carga/descarga repetida de sectores: latencia, hitch y memoria.
##
## Sustituye al recorrido de 10 minutos por 60 ciclos de carga/descarga, que
## ejercitan el mismo camino sin alargar la CI.

const SECTOR_A: String = "res://tests/scenes/sectors/sector_a.tscn"
const WARMUP_CYCLES: int = 3
const MEASURED_CYCLES: int = 60
const MAX_LOAD_MS: float = 150.0
const MAX_HITCH_MS: float = 50.0
const MAX_MEMORY_GROWTH_KB: int = 8192

var _hitch_ms: float = 0.0


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
	var definitions: Array[SectorDefinition] = [_definition(&"a", SECTOR_A)]
	streamer.sectors = definitions
	stage.add_child(streamer)
	for _i: int in WARMUP_CYCLES:
		if not await _cycle(streamer, target):
			printerr("STREAMING_SOAK_FAIL warmup")
			quit(1)
			return
	var baseline_kb: int = OS.get_static_memory_usage() / 1024
	var total_ms: float = 0.0
	var worst_ms: float = 0.0
	var worst_hitch: float = 0.0
	for _i: int in MEASURED_CYCLES:
		var start: int = Time.get_ticks_usec()
		if not await _cycle(streamer, target):
			printerr("STREAMING_SOAK_FAIL cycle")
			quit(1)
			return
		var elapsed: float = float(Time.get_ticks_usec() - start) / 1000.0
		total_ms += elapsed
		worst_ms = maxf(worst_ms, elapsed)
		worst_hitch = maxf(worst_hitch, _last_hitch())
	var growth_kb: int = OS.get_static_memory_usage() / 1024 - baseline_kb
	var average_ms: float = total_ms / float(MEASURED_CYCLES)
	var ok: bool = average_ms <= MAX_LOAD_MS and worst_ms <= MAX_LOAD_MS
	ok = ok and worst_hitch <= MAX_HITCH_MS
	ok = ok and growth_kb <= MAX_MEMORY_GROWTH_KB
	var message: String = (
		"loads=%d avg_ms=%.1f max_ms=%.1f max_hitch_ms=%.1f memory_kb=%d"
		% [MEASURED_CYCLES, average_ms, worst_ms, worst_hitch, growth_kb]
	)
	if ok:
		print("STREAMING_SOAK_OK ", message)
	else:
		printerr("STREAMING_SOAK_FAIL ", message)
	stage.queue_free()
	await process_frame
	quit(0 if ok else 1)


func _last_hitch() -> float:
	return _hitch_ms


## Un ciclo: descarga en la celda 3 y vuelve a cargar en la celda 0.
func _cycle(streamer: SectorStreamer, target: Node3D) -> bool:
	target.global_position = Vector3(768.0, 0.0, 0.0)
	if not await _wait(streamer, false):
		return false
	target.global_position = Vector3(0.0, 0.0, 0.0)
	return await _wait(streamer, true)


func _wait(streamer: SectorStreamer, loaded: bool) -> bool:
	var deadline: int = Time.get_ticks_msec() + 5000
	var last: int = Time.get_ticks_usec()
	while Time.get_ticks_msec() < deadline:
		await process_frame
		var now: int = Time.get_ticks_usec()
		_hitch_ms = maxf(_hitch_ms, float(now - last) / 1000.0)
		last = now
		if streamer.is_loaded(&"a") == loaded:
			return true
	return false


func _definition(id: StringName, scene_path: String) -> SectorDefinition:
	var definition: SectorDefinition = SectorDefinition.new()
	definition.id = id
	definition.grid_position = Vector2i(0, 0)
	definition.scene_path = scene_path
	return definition
