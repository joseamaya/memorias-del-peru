extends SceneTree
## Auditoría de una escena: draw calls, primitivas, memoria de vídeo, luces con
## sombra, mallas, colisiones y tamaño del script raíz.
##
##   godot --path . -s res://tools/scene_audit.gd -- \
##       --scene=res://campaigns/01_pachacutec/scenes/world/ciudad.tscn \
##       --frames=20 --out=/tmp/ciudad_audit.json
##
## Sin `--headless`: el servidor de render Dummy no cuenta draw calls. Se usa
## como termómetro, no como benchmark: para FPS está `measure_performance.tscn`.

const DEFAULT_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/ciudad.tscn"

var _scene_path: String = DEFAULT_SCENE
var _frames: int = 20
var _out_path: String = ""


func _initialize() -> void:
	for arg: String in OS.get_cmdline_user_args():
		if arg.begins_with("--scene="):
			_scene_path = arg.trim_prefix("--scene=")
		elif arg.begins_with("--frames="):
			_frames = maxi(arg.trim_prefix("--frames=").to_int(), 1)
		elif arg.begins_with("--out="):
			_out_path = arg.trim_prefix("--out=")
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(_scene_path) as PackedScene
	if packed == null:
		printerr("SCENE_AUDIT_FAIL no se pudo cargar ", _scene_path)
		quit(1)
		return
	var scene: Node = packed.instantiate()
	root.add_child(scene)
	for _i: int in range(_frames):
		await process_frame
	var report: Dictionary = _build_report(scene)
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
