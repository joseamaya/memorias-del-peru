extends SceneTree
## Auditoría de una escena: draw calls, primitivas, memoria de vídeo, luces con
## sombra, mallas, colisiones y tamaño del script raíz.
##
##   godot --path . -s res://tools/scene_audit.gd -- \
##       --scene=res://campaigns/01_pachacutec/scenes/world/region_world.tscn \
##       --frames=20 --out=/tmp/ciudad_audit.json
##
## Con `--breakdown` oculta cada grupo de primer nivel y mide cuántos draw
## calls aporta. Sirve para decidir dónde optimizar antes de tocar la escena.
##
## Sin `--headless`: el servidor de render Dummy no cuenta draw calls. Se usa
## como termómetro, no como benchmark: para FPS está `measure_performance.tscn`.

const DEFAULT_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
## Fotogramas de asentamiento tras ocultar o mostrar un grupo.
const SETTLE_FRAMES: int = 4

var _scene_path: String = DEFAULT_SCENE
var _frames: int = 20
var _out_path: String = ""
var _breakdown: bool = false


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			_scene_path = arg.trim_prefix("--scene=")
		elif arg.begins_with("--frames="):
			_frames = maxi(arg.trim_prefix("--frames=").to_int(), 1)
		elif arg.begins_with("--out="):
			_out_path = arg.trim_prefix("--out=")
		elif arg == "--breakdown":
			_breakdown = true
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(_scene_path) as PackedScene
	if packed == null:
		printerr("SCENE_AUDIT_FAIL no se pudo cargar ", _scene_path)
		quit(1)
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	var baseline: float = await _measure_draw_calls(_frames)
	var report: Dictionary = _build_report(scene)
	report["draw_calls"] = int(roundf(baseline))
	if _breakdown:
		report["groups"] = await _group_breakdown(scene, baseline)
	print("SCENE_AUDIT ", JSON.stringify(report))
	if not _out_path.is_empty():
		var file: FileAccess = FileAccess.open(_out_path, FileAccess.WRITE)
		if file != null:
			file.store_string(JSON.stringify(report, "  "))
			file.close()
	_stop_audio(scene)
	scene.queue_free()
	await process_frame
	await process_frame
	quit(0)


## Media de draw calls durante [param frames], tras dejar que la escena se
## asiente y que los ModelSlot terminen de cargar.
func _measure_draw_calls(frames: int) -> float:
	for _i: int in range(SETTLE_FRAMES):
		await process_frame
	var total: int = 0
	for _i: int in range(maxi(frames, 1)):
		await process_frame
		total += int(Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME))
	return float(total) / float(maxi(frames, 1))


## Aportación de cada grupo de primer nivel. El delta incluye también su pase
## de sombra, que es justo lo que interesa al ajustar el presupuesto.
func _group_breakdown(scene: Node, baseline: float) -> Array[Dictionary]:
	var groups: Array[Dictionary] = []
	for child: Node in scene.get_children():
		var node3d: Node3D = child as Node3D
		if node3d == null or not node3d.visible:
			continue
		var meshes: int = child.find_children("*", "MeshInstance3D", true, false).size()
		var multimeshes: int = child.find_children("*", "MultiMeshInstance3D", true, false).size()
		var light: bool = child is Light3D
		if meshes == 0 and multimeshes == 0 and not light:
			continue
		node3d.visible = false
		var hidden: float = await _measure_draw_calls(maxi(int(_frames / 2.0), 5))
		node3d.visible = true
		(
			groups
			. append(
				{
					"name": String(child.name),
					"draw_calls": int(roundf(baseline - hidden)),
					"mesh_instances": meshes,
					"multimesh_instances": multimeshes,
				}
			)
		)
	groups.sort_custom(
		func(a: Dictionary, b: Dictionary) -> bool:
			var left: int = a["draw_calls"]
			var right: int = b["draw_calls"]
			return left > right
	)
	return groups


func _build_report(scene: Node) -> Dictionary:
	var meshes: int = scene.find_children("*", "MeshInstance3D", true, false).size()
	var multimeshes: int = scene.find_children("*", "MultiMeshInstance3D", true, false).size()
	var bodies: int = scene.find_children("*", "CollisionObject3D", true, false).size()
	var shapes: int = scene.find_children("*", "CollisionShape3D", true, false).size()
	var shadow_lights: int = 0
	for node: Node in scene.find_children("*", "Light3D", true, false):
		if (node as Light3D).shadow_enabled:
			shadow_lights += 1
	return {
		"scene": _scene_path,
		"draw_calls": Performance.get_monitor(Performance.RENDER_TOTAL_DRAW_CALLS_IN_FRAME),
		"primitives": Performance.get_monitor(Performance.RENDER_TOTAL_PRIMITIVES_IN_FRAME),
		"video_mem_mb": Performance.get_monitor(Performance.RENDER_VIDEO_MEM_USED) / 1048576.0,
		"mesh_instances": meshes,
		"multimesh_instances": multimeshes,
		"collision_bodies": bodies,
		"collision_shapes": shapes,
		"shadow_lights": shadow_lights,
		"budget_draw_calls": 350,
		"budget_primitives": 1200000,
	}


func _stop_audio(scene: Node) -> void:
	for node: Node in scene.find_children("*", "AudioStreamPlayer", true, false):
		(node as AudioStreamPlayer).stop()
	for node: Node in scene.find_children("*", "AudioStreamPlayer3D", true, false):
		(node as AudioStreamPlayer3D).stop()
