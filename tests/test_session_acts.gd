extends RefCounted
## Comprueba que cada mundo marca su acto en el registro de sesión, que es lo
## que permite medir la duración real con `tools/session_duration.py`.

const TEST_DIR: String = "user://sesiones_test_actos"
const WORLDS: Array[String] = [
	"res://campaigns/01_pachacutec/scenes/world/llacta.tscn",
	"res://campaigns/01_pachacutec/scenes/world/paso.tscn",
	"res://campaigns/01_pachacutec/scenes/world/ciudad.tscn",
	"res://campaigns/01_pachacutec/scenes/world/llacta_act4.tscn",
	"res://campaigns/01_pachacutec/scenes/world/llacta_act5.tscn",
]
const ACT_MARKS: Array[String] = ["llacta", "paso", "cusco", "posguerra", "obra"]


func test_worlds_mark_their_act() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var service: SessionLogService = tree.root.get_node_or_null("SessionLog") as SessionLogService
	if service == null:
		return false
	if service.is_active():
		# Una sesión real en curso manda: no se interfiere con ella.
		return true
	if not service.start("ACTOS-TEST", TEST_DIR):
		return false
	CampaignState.clear()
	var ok: bool = true
	for path: String in WORLDS:
		var packed: PackedScene = load(path) as PackedScene
		if packed == null:
			ok = false
			continue
		var world: Node = packed.instantiate()
		if world == null:
			ok = false
			continue
		tree.root.add_child(world)
		world.free()
	service.finish("prueba")
	var log_path: String = service.get_log_path()
	var content: String = ""
	var file: FileAccess = FileAccess.open(log_path, FileAccess.READ)
	if file != null:
		content = file.get_as_text()
	for mark: String in ACT_MARKS:
		if not content.contains("\tact\t" + mark):
			printerr("Falta la marca de acto «", mark, "»")
			ok = false
	CampaignState.clear()
	_cleanup(log_path)
	return ok


func _cleanup(path: String) -> void:
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)
	var directory: String = ProjectSettings.globalize_path(TEST_DIR)
	if DirAccess.dir_exists_absolute(directory):
		DirAccess.remove_absolute(directory)
