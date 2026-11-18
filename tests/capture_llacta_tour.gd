extends Node
## Capturas fijas de la llacta para revisar la composición del territorio.
##
##   godot --path . --resolution 1280x720 \
##       res://tests/scenes/capture_llacta_tour.tscn

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"
const OUTPUT_DIR: String = "/tmp/opencode/llacta_tour"
const SHOT_NAMES: Array[String] = [
	"1_plaza", "2_casa", "3_manantial", "4_mirador", "5_paso_norte", "6_terrazas", "7_corral",
]
const SHOT_FROM: Array[Vector3] = [
	Vector3(0.0, 0.05, 12.0),
	Vector3(14.0, 0.05, 7.0),
	Vector3(22.0, 0.05, 4.0),
	Vector3(0.0, 0.05, -69.0),
	Vector3(0.0, 0.05, -35.0),
	Vector3(28.0, 0.05, 0.0),
	Vector3(-19.0, 0.05, -14.0),
]
const SHOT_PITCH: Array[float] = [0.0, 0.0, 0.0, -0.06, 0.0, 0.0, 0.0]
const SHOT_TO: Array[Vector3] = [
	Vector3(0.0, 0.05, 0.0),
	Vector3(20.0, 0.05, 5.5),
	Vector3(29.0, 0.05, 4.0),
	Vector3(0.0, 0.05, -95.0),
	Vector3(0.0, 0.05, -80.0),
	Vector3(45.0, 0.05, 0.0),
	Vector3(-31.0, 0.05, -12.0),
]


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	CampaignState.clear()
	CampaignState.set_flag(&"intro_vista", 1)
	DirAccess.make_dir_recursive_absolute(OUTPUT_DIR)
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		get_tree().quit(1)
		return
	var world: Node = packed.instantiate()
	add_child(world)
	await _frames(12)
	var player: PlayerFPS = world.get_node_or_null("PlayerFPS") as PlayerFPS
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	if player == null:
		get_tree().quit(1)
		return
	if hud != null:
		hud.visible = false
	var hands: Node3D = player.get_node_or_null("Head/Camera3D/FirstPersonHands") as Node3D
	if hands != null:
		hands.visible = false
	var weapon: Node3D = player.get_node_or_null("Head/Camera3D/FirstPersonWeapon") as Node3D
	if weapon != null:
		weapon.visible = false
	for index: int in range(SHOT_NAMES.size()):
		player.global_position = SHOT_FROM[index]
		var to: Vector3 = SHOT_TO[index] - player.global_position
		player.rotation.y = atan2(-to.x, -to.z)
		player.set("_pitch", SHOT_PITCH[index])
		player.head.rotation.x = SHOT_PITCH[index]
		await _frames(8)
		var image: Image = get_viewport().get_texture().get_image()
		image.save_png("%s/%s.png" % [OUTPUT_DIR, SHOT_NAMES[index]])
		print("CAPTURA_LLACTA ", SHOT_NAMES[index])
	print("CAPTURA_LLACTA_OK")
	world.queue_free()
	await _frames(10)
	CampaignState.clear()
	get_tree().quit(0)


func _frames(count: int) -> void:
	for _index: int in range(count):
		await get_tree().process_frame
