extends Node
## Herramienta de desarrollo: captura el HUD de exploración y el diálogo.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_hud.tscn
##
## Guarda dos PNG en `user://`. No forma parte del juego.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const INTRO_NEVER: int = 2


func _ready() -> void:
	_capture.call_deferred()


func _capture() -> void:
	var world: Node3D = (load(WORLD_PATH) as PackedScene).instantiate() as Node3D
	world.set("intro_mode", INTRO_NEVER)
	add_child(world)
	await get_tree().process_frame
	var event: Node = world.get_node("EventController")
	event.set_process(false)
	var player: PlayerFPS = world.get_node("PlayerFPS") as PlayerFPS
	var weaver: NpcActor = world.get_node("Llacta/NPCs/Tejedora") as NpcActor
	var talk: NpcTalk = weaver.get_node("Talk") as NpcTalk
	var shadow_node: MeshInstance3D = weaver.get_node_or_null("ContactShadow") as MeshInstance3D
	if shadow_node != null:
		print("SHADOW_MAT ", shadow_node.material_override)
		if shadow_node.material_override is ShaderMaterial:
			var sm: ShaderMaterial = shadow_node.material_override as ShaderMaterial
			print("  shader=", sm.shader, " code=", sm.shader.code.length() if sm.shader != null else -1)
		print("  exists old=", ResourceLoader.exists("res://shared_assets/materials/sombra_contacto.gdshader"),
			" new=", ResourceLoader.exists("res://shared_assets/materials/sombra_contacto_v2.gdshader"))



	# Exploración: delante de la tejedora, dentro del alcance de «Hablar».
	var forward: Vector3 = -weaver.global_transform.basis.z
	player.global_position = weaver.global_position + forward * 2.0
	player.rotation.y = atan2(forward.x, forward.z)
	var head: Node3D = player.get_node("Head") as Node3D
	head.rotation.x = deg_to_rad(-8.0)
	await _wait(12)
	player.update_interaction()
	await _wait(4)
	_save("hud_exploration")

	# Diálogo: la cámara encuadra a la tejedora y el HUD de exploración se va.
	player.global_position = weaver.global_position + forward * 2.0
	player.rotation.y = atan2(forward.x, forward.z)
	talk.interact(player)
	await _wait(35)
	print("DEBUG player=", player.global_position, " weaver=", weaver.global_position,
		" yaw=", rad_to_deg(player.rotation.y), " pitch=", player.get("_pitch"),
		" head=", rad_to_deg(head.rotation.x), " lock=", player.is_controls_locked(),
		" focus=", player.get("_focus_phase"))
	_save("hud_dialogue")
	print("CAPTURA_HUD_OK")
	var manager: Node = get_node_or_null("/root/GameManager")
	if manager != null:
		manager.call("request_quit", 0)
	else:
		get_tree().quit()


func _wait(frames: int) -> void:
	for _i: int in range(frames):
		await get_tree().process_frame


func _save(file_name: String) -> void:
	var image: Image = get_viewport().get_texture().get_image()
	image.save_png("user://" + file_name + ".png")
	print("CAPTURA ", file_name)
