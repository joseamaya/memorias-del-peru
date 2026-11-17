extends RefCounted
## Pruebas de los cuerpos Quaternius del prototipo.
##
## Comprueban que los GLB conservan el rig de 65 huesos, las medidas, los
## materiales y que `QuaterniusClips` añade los clips lógicos sin depender de
## un AnimationPlayer dentro del GLB.

const MODELS: Array[String] = [
	"pch_npc_mensajero_q.glb",
	"pch_npc_sisa_q.glb",
	"pch_npc_curaca_q.glb",
	"pch_npc_chanca_q.glb",
]
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const FACE_DIR: String = "res://shared_assets/characters/quaternius/faces/"
const FACE_TEXTURES: Array[String] = [
	"pch_face_mensajero.png", "pch_face_sisa.png",
	"pch_face_curaca.png", "pch_face_chanca.png",
]
const BODY_MATERIALS: Dictionary[String, String] = {
	"pch_npc_mensajero_q.glb": "pch.body_mensajero",
	"pch_npc_sisa_q.glb": "pch.body_sisa",
	"pch_npc_curaca_q.glb": "pch.body_curaca",
	"pch_npc_chanca_q.glb": "pch.body_chanca",
}
const REQUIRED_CLIPS: Array[StringName] = [
	&"idle", &"walk", &"run", &"talk", &"attack", &"hit", &"death",
]


func test_quaternius_faces() -> bool:
	var ok: bool = true
	for file_name: String in FACE_TEXTURES:
		var texture: Texture2D = load(FACE_DIR + file_name) as Texture2D
		if texture == null:
			printerr("No carga la cara ", file_name)
			ok = false
		elif texture.get_width() != 1024 or texture.get_height() != 1024:
			printerr(file_name, ": tamaño inesperado ", texture.get_size())
			ok = false
	for file_name: String in BODY_MATERIALS:
		var packed: PackedScene = load(MODEL_DIR + file_name) as PackedScene
		var model: Node3D = packed.instantiate() as Node3D
		var body: MeshInstance3D = model.find_child("Body", true, false) as MeshInstance3D
		if body == null:
			printerr(file_name, ": falta Body")
			ok = false
			model.free()
			continue
		var source: BaseMaterial3D = body.mesh.surface_get_material(0) as BaseMaterial3D
		var expected: String = BODY_MATERIALS[file_name]
		if source == null:
			printerr(file_name, ": el cuerpo no trae material")
			ok = false
		elif source.resource_name != expected:
			printerr(file_name, ": material de cuerpo ", source.resource_name)
			ok = false
		SurfaceMaterials.apply_to_model(model)
		var skin: StandardMaterial3D = body.get_surface_override_material(0) as StandardMaterial3D
		if skin == null or skin.albedo_texture == null or skin.albedo_texture.get_width() != 1024:
			printerr(file_name, ": la piel no usa la textura de cara")
			ok = false
		elif skin.roughness_texture == null:
			printerr(file_name, ": la piel no usa el mapa de rugosidad")
			ok = false
		var brows: MeshInstance3D = model.find_child("Eyebrows", true, false) as MeshInstance3D
		if brows == null:
			printerr(file_name, ": faltan las cejas")
			ok = false
		else:
			var brow_material: BaseMaterial3D = brows.mesh.surface_get_material(0) as BaseMaterial3D
			if brow_material == null or not brow_material.resource_name.begins_with("pch.brow_"):
				printerr(file_name, ": material de cejas inesperado")
				ok = false
		model.free()
	return ok


func test_quaternius_assets() -> bool:
	var ok: bool = true
	for file_name: String in MODELS:
		var packed: PackedScene = load(MODEL_DIR + file_name) as PackedScene
		if packed == null:
			printerr("No carga ", file_name)
			ok = false
			continue
		var model: Node3D = packed.instantiate() as Node3D
		var errors: PackedStringArray = AssetValidation.validate_model(model, file_name)
		if not errors.is_empty():
			printerr(file_name, ": ", errors)
			ok = false
		var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false) as Skeleton3D
		if skeleton == null or skeleton.get_bone_count() != 65:
			printerr(file_name, ": esqueleto inesperado")
			ok = false
		if skeleton != null:
			if skeleton.find_bone("Head") < 0 or skeleton.find_bone("hand_r") < 0:
				printerr(file_name, ": faltan Head o hand_r")
				ok = false
		if not QuaterniusClips.is_quaternius(model):
			printerr(file_name, ": no se reconoce como Quaternius")
			ok = false
		var player: AnimationPlayer = QuaterniusClips.ensure_player(model)
		for clip: StringName in REQUIRED_CLIPS:
			if player == null or not player.has_animation(clip):
				printerr(file_name, ": falta el clip ", clip)
				ok = false
		if player != null:
			# UAL2 sustituye idle alterno, trabajo y reacción al golpe.
			if not player.has_animation(&"idle_b") or player.get_animation(&"idle_b").length < 2.5:
				printerr(file_name, ": idle_b no viene de UAL2")
				ok = false
			if not player.has_animation(&"work") or player.get_animation(&"work").length < 2.7:
				printerr(file_name, ": work no viene de UAL2")
				ok = false
			if not player.has_animation(&"hit") or player.get_animation(&"hit").length < 0.8:
				printerr(file_name, ": hit no viene de UAL2")
				ok = false
		var meshes: Array[Node] = model.find_children("*", "MeshInstance3D", true, false)
		if meshes.size() > 7:
			printerr(file_name, ": demasiadas mallas ", meshes.size())
			ok = false
		model.free()
	return ok


func test_quaternius_npc_actor() -> bool:
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/npcs/npc_actor.tscn") as PackedScene
	var actor: NpcActor = packed.instantiate() as NpcActor
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	tree.root.add_child(actor)
	var model_packed: PackedScene = load(MODEL_DIR + "pch_npc_mensajero_q.glb") as PackedScene
	var model: Node3D = model_packed.instantiate() as Node3D
	var body: MeshInstance3D = actor.get_node("Body") as MeshInstance3D
	body.add_child(model)
	actor.preserve_materials = true
	actor.target_height = 1.60
	actor.set_model(model)
	var ok: bool = actor.is_animated()
	ok = ok and actor.current_animation() == &"idle"
	ok = ok and actor.look_modifier() != null
	ok = ok and actor.focus_point().y > 1.0
	actor.free()
	return ok


func test_catalog_switch() -> bool:
	# El catálogo no debe cambiar el set por defecto en una partida normal.
	var legacy: String = CharacterCatalog.model_for("Curaca", "pch_npc_curaca.glb")
	return legacy == "pch_npc_curaca.glb" or CharacterCatalog.enabled()
