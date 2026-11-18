extends RefCounted
## Pruebas de los cuerpos Quaternius del elenco.
##
## Comprueban que los GLB conservan el rig de 76 huesos, las medidas, los
## materiales y que `QuaterniusClips` añade los clips lógicos sin depender de
## un AnimationPlayer dentro del GLB.

const MODELS: Array[String] = [
	"pch_npc_mensajero_q.glb",
	"pch_npc_sisa_q.glb",
	"pch_npc_curaca_q.glb",
	"pch_npc_chanca_q.glb",
	"pch_npc_anciana_q.glb",
	"pch_npc_joven_q.glb",
	"pch_npc_madre_q.glb",
	"pch_npc_hermano_q.glb",
	"pch_npc_puma_q.glb",
	"pch_npc_anca_q.glb",
]
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const FACE_DIR: String = "res://shared_assets/characters/quaternius/faces/"
const FACE_TEXTURES: Array[String] = [
	"pch_face_mensajero.png", "pch_face_sisa.png",
	"pch_face_curaca.png", "pch_face_chanca.png",
	"pch_face_anciana.png", "pch_face_joven.png",
	"pch_face_madre.png", "pch_face_hermano.png",
	"pch_face_puma.png", "pch_face_anca.png",
]
const BODY_MATERIALS: Dictionary[String, String] = {
	"pch_npc_mensajero_q.glb": "pch.body_mensajero",
	"pch_npc_sisa_q.glb": "pch.body_sisa",
	"pch_npc_curaca_q.glb": "pch.body_curaca",
	"pch_npc_chanca_q.glb": "pch.body_chanca",
	"pch_npc_anciana_q.glb": "pch.body_anciana",
	"pch_npc_joven_q.glb": "pch.body_joven",
	"pch_npc_madre_q.glb": "pch.body_madre",
	"pch_npc_hermano_q.glb": "pch.body_hermano",
	"pch_npc_puma_q.glb": "pch.body_puma",
	"pch_npc_anca_q.glb": "pch.body_anca",
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
		var clothes: MeshInstance3D = model.find_child("Clothes", true, false) as MeshInstance3D
		if clothes == null:
			printerr(file_name, ": falta Clothes")
			ok = false
		else:
			var cloth_material: BaseMaterial3D = clothes.mesh.surface_get_material(0) as BaseMaterial3D
			if cloth_material == null or cloth_material.albedo_texture == null:
				printerr(file_name, ": la ropa no trae el textil embebido")
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
		if skeleton == null or skeleton.get_bone_count() != 76:
			printerr(file_name, ": esqueleto inesperado")
			ok = false
		if skeleton != null:
			if skeleton.find_bone("Head") < 0 or skeleton.find_bone("hand_r") < 0:
				printerr(file_name, ": faltan Head o hand_r")
				ok = false
			if skeleton.find_bone("Jaw") < 0:
				printerr(file_name, ": falta el hueso de mandíbula")
				ok = false
			for bone: String in ["Blink_L", "Blink_R", "Brow_L", "Brow_R"]:
				if skeleton.find_bone(bone) < 0:
					printerr(file_name, ": falta el hueso de expresión ", bone)
					ok = false
			for chain: String in CapeSprings.CHAINS:
				if (skeleton.find_bone("Cape_%s_1" % chain) < 0
					or skeleton.find_bone("Cape_%s_2" % chain) < 0):
					printerr(file_name, ": falta la cadena de manto ", chain)
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
	ok = ok and actor.spring_simulator() != null
	ok = ok and actor.character_face() != null and actor.character_face().jaw_index() >= 0
	ok = ok and actor.character_face().has_expression_bones()
	ok = ok and actor.focus_point().y > 1.0
	actor.free()
	return ok


func test_catalog_models() -> bool:
	# Todos los papeles del juego usan un GLB Q existente; no queda legado.
	var ok: bool = CharacterCatalog.model_for("Curaca") == "pch_npc_curaca_q.glb"
	ok = ok and CharacterCatalog.model_for("HijoPuma") == "pch_npc_joven_q.glb"
	ok = ok and CharacterCatalog.model_for("Tejedora") == "pch_npc_anca_q.glb"
	ok = ok and CharacterCatalog.model_for("villager", 1) == "pch_npc_madre_q.glb"
	for role: String in CharacterCatalog.MODELS:
		var file_name: String = CharacterCatalog.model_for(role)
		if not CharacterCatalog.is_quaternius_file(file_name):
			printerr(role, ": modelo no Q ", file_name)
			ok = false
		elif not ResourceLoader.exists(MODEL_DIR + file_name):
			printerr(role, ": falta ", file_name)
			ok = false
	return ok


func test_hijopuma_height() -> bool:
	# Decisión cerrada: no hay base infantil gratuita en UBC Standard
	# (Regular/Teen son Source de pago). HijoPuma es el Joven Q a 1,20 m.
	var height: float = Llacta.CHARACTER_HEIGHTS["HijoPuma"]
	if not is_equal_approx(height, 1.20):
		printerr("HijoPuma: altura ", height, " en vez de 1,20 m")
		return false
	return CharacterCatalog.model_for("HijoPuma") == "pch_npc_joven_q.glb"


func test_quaternius_shadow_policy() -> bool:
	# El pase de sombra solo conserva cuerpo y ropa: ojos, cejas, pelo y tupu
	# no aportan a la silueta y cuestan draw calls. Es la optimización que baja
	# el Cusco y la llacta por debajo del presupuesto.
	var ok: bool = true
	for file_name: String in MODELS:
		var packed: PackedScene = load(MODEL_DIR + file_name) as PackedScene
		var model: Node3D = packed.instantiate() as Node3D
		QuaterniusMaterials.apply_shadow_policy(model)
		var casters: int = 0
		for node: Node in model.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance: MeshInstance3D = node as MeshInstance3D
			var expected: bool = QuaterniusMaterials.uses_material(
				mesh_instance, QuaterniusMaterials.SHADOW_MATERIALS)
			var casts: bool = (mesh_instance.cast_shadow
				== GeometryInstance3D.SHADOW_CASTING_SETTING_ON)
			if casts != expected:
				printerr(file_name, ": sombra inesperada en ", mesh_instance.name)
				ok = false
			if expected:
				casters += 1
		if casters < 2:
			printerr(file_name, ": sin cuerpo y ropa en el pase de sombra")
			ok = false
		model.free()
	return ok


func test_quaternius_crowd_lod() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "CrowdTest"
	visual.model_path = MODEL_DIR + "pch_npc_sisa_q.glb"
	visual.crowd = true
	tree.root.add_child(visual)
	var model: Node3D = visual.model()
	var ok: bool = model != null
	if model != null:
		for node: Node in model.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance: MeshInstance3D = node as MeshInstance3D
			var hidden: bool = QuaterniusMaterials.uses_material(
				mesh_instance, CharacterModelVisual.CROWD_HIDDEN_MATERIALS)
			if mesh_instance.visible == hidden:
				printerr("multitud: visibilidad inesperada en ", mesh_instance.name)
				ok = false
	visual.free()
	return ok


func test_quaternius_cape_springs() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "CapeTest"
	visual.model_path = MODEL_DIR + "pch_npc_curaca_q.glb"
	tree.root.add_child(visual)
	var springs: SpringBoneSimulator3D = visual.spring_simulator()
	var ok: bool = springs != null and springs.setting_count == 3
	ok = ok and visual.character_face() != null and visual.character_face().jaw_index() >= 0
	ok = ok and visual.character_face().has_expression_bones()
	var crowd: CharacterModelVisual = CharacterModelVisual.new()
	crowd.name = "CapeCrowdTest"
	crowd.model_path = MODEL_DIR + "pch_npc_sisa_q.glb"
	crowd.crowd = true
	tree.root.add_child(crowd)
	ok = ok and crowd.spring_simulator() == null
	crowd.free()
	visual.free()
	return ok


func test_character_face() -> bool:
	var packed: PackedScene = load(MODEL_DIR + "pch_npc_curaca_q.glb") as PackedScene
	var model: Node3D = packed.instantiate() as Node3D
	var face: CharacterFace = CharacterFace.new(model)
	var ok: bool = face.jaw_index() >= 0
	face.update(0.1, true)
	ok = ok and face.open_amount() > 0.0
	face.update(0.1, false)
	ok = ok and face.open_amount() == 0.0
	model.free()
	return ok


func test_character_expressions() -> bool:
	var packed: PackedScene = load(MODEL_DIR + "pch_npc_curaca_q.glb") as PackedScene
	var model: Node3D = packed.instantiate() as Node3D
	var face: CharacterFace = CharacterFace.new(model)
	var ok: bool = face.has_expression_bones()
	face.update(0.2, true)
	ok = ok and face.brow_amount() > 0.5
	# En un minuto de reposo debe parpadear varias veces aunque el intervalo
	# sea aleatorio.
	for _index: int in range(600):
		face.update(0.1, false)
	ok = ok and face.blink_count() >= 3
	face.set_expression(1.0, 1.0)
	ok = ok and is_equal_approx(face.blink_amount(), 1.0)
	ok = ok and is_equal_approx(face.brow_amount(), 1.0)
	var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false) as Skeleton3D
	if skeleton != null:
		var blink_bone: int = skeleton.find_bone("Blink_L")
		var brow_bone: int = skeleton.find_bone("Brow_L")
		ok = ok and absf(skeleton.get_bone_pose_position(blink_bone).y
			- skeleton.get_bone_rest(blink_bone).origin.y) > 0.01
		ok = ok and absf(skeleton.get_bone_pose_position(brow_bone).y
			- skeleton.get_bone_rest(brow_bone).origin.y) > 0.002
	face.clear_expression()
	ok = ok and face.blink_amount() == 0.0
	ok = ok and face.brow_amount() == 0.0
	model.free()
	return ok
