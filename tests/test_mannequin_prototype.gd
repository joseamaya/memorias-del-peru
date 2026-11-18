extends RefCounted
## Pruebas del prototipo de maniquíes: looks, atuendo, nodo visual y antebrazo UAL1.
##
## El estilo nuevo usa el mismo GLB de Quaternius para todos: dos superficies y
## piezas primitivas colgadas de huesos reales. No hay caras ni texturas.

const MANNEQUIN: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"
const FOREARM: String = "res://shared_assets/characters/mannequin/mannequin_forearm.glb"


func _model() -> Node3D:
	var packed: PackedScene = load(MANNEQUIN) as PackedScene
	return packed.instantiate() as Node3D if packed != null else null


func test_mannequin_looks_use_real_bones() -> bool:
	var model: Node3D = _model()
	if model == null:
		return false
	var skeleton: Skeleton3D = CharacterOutfit.find_skeleton(model)
	var ok: bool = skeleton != null
	var looks: Array[CharacterLook] = MannequinLooks.all()
	ok = ok and looks.size() == 10
	for look: CharacterLook in looks:
		ok = ok and look.parts.size() >= 3
		for part: LookPart in look.parts:
			ok = ok and skeleton.find_bone(part.bone) >= 0
			ok = ok and CharacterOutfit.mesh_for(part) != null
	# Las autoridades locales no llevan orejeras ni oro (guía visual).
	for part: LookPart in MannequinLooks.curaca().parts:
		ok = ok and not part.name.begins_with("Orejera")
	model.free()
	return ok


func test_outfit_applies_surfaces_and_pieces() -> bool:
	var model: Node3D = _model()
	if model == null:
		return false
	var look: CharacterLook = MannequinLooks.curaca()
	CharacterOutfit.apply(model, look)
	var skeleton: Skeleton3D = CharacterOutfit.find_skeleton(model)
	var body: MeshInstance3D = skeleton.find_child("Mannequin", false, false) as MeshInstance3D
	var skin: StandardMaterial3D = body.get_surface_override_material(0) as StandardMaterial3D
	var joints: StandardMaterial3D = body.get_surface_override_material(1) as StandardMaterial3D
	var ok: bool = skin != null and skin.albedo_color == look.skin
	ok = ok and joints != null and joints.albedo_color == look.joints
	ok = ok and CharacterOutfit.piece_count(model) == look.parts.size()
	# Vestir de nuevo sustituye el atuendo, no lo acumula.
	CharacterOutfit.apply(model, MannequinLooks.chanca())
	ok = ok and CharacterOutfit.piece_count(model) == MannequinLooks.chanca().parts.size()
	model.free()
	return ok


func test_outfit_mannequin_node() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var node: OutfitMannequin = OutfitMannequin.new()
	node.look = MannequinLooks.sisa()
	node.target_height = 1.55
	node.clip = &"Idle"
	tree.root.add_child(node)
	var ok: bool = node.model() != null
	ok = ok and node.outfit_piece_count() == MannequinLooks.sisa().parts.size()
	node.free()
	return ok


func test_mannequin_forearm_asset() -> bool:
	var packed: PackedScene = load(FOREARM) as PackedScene
	if packed == null:
		return false
	var forearm: Node3D = packed.instantiate() as Node3D
	var meshes: Array[Node] = forearm.find_children("*", "MeshInstance3D", true, false)
	var ok: bool = meshes.size() == 1
	if not meshes.is_empty():
		var mesh: MeshInstance3D = meshes[0] as MeshInstance3D
		ok = ok and mesh.mesh != null and mesh.mesh.get_surface_count() == 2
		ok = ok and mesh.mesh.get_aabb().size.x > 0.1
		ok = ok and mesh.mesh.get_aabb().size.y > 0.05
	forearm.free()
	return ok
