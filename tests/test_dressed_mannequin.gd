extends RefCounted
## Comprueba el maniquí vestido del acto I (ADR-0042): la tejedora usa el
## modelo completo vestido en Blender y el resto conserva las capas ancladas
## a los huesos del UAL1. Ningún personaje carga los modelos viejos.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MANNEQUIN_PATH: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"
const WEAVER_MODEL: String = "res://campaigns/01_pachacutec/assets/models/pch_weaver_dressed.glb"
const EXPECTED_ROLES: Dictionary[String, StringName] = {
	"Tejedora": &"weaver",
	"Agricultor": &"farmer",
	"Mensajero": &"messenger",
	"Curaca": &"curaca",
	"Principal1": &"principal",
	"Principal2": &"principal",
	"Habitante1": &"villager",
	"Habitante2": &"villager",
	"Habitante3": &"villager",
}


func _spawn_world() -> Node:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return null
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	return world


func _outfit_of(world: Node, npc_name: String) -> DressedMannequin:
	var npc: NpcActor = world.get_node_or_null("Llacta/NPCs/%s" % npc_name) as NpcActor
	if npc == null:
		return null
	return npc.get_node_or_null("Outfit") as DressedMannequin


func test_dressed_weaver() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var weaver: NpcActor = world.get_node_or_null("Llacta/NPCs/Tejedora") as NpcActor
	var slot: ModelSlot = null
	if weaver != null:
		slot = weaver.get_node_or_null("Body/ModelSlot") as ModelSlot
	var ok: bool = weaver != null and slot != null and slot.model != null
	if not ok:
		world.free()
		return false
	ok = ok and slot.loaded_path == WEAVER_MODEL
	ok = ok and weaver.preserve_materials and not weaver.mannequin_skin
	ok = ok and weaver.current_animation() == &"idle"
	# El modelo conserva el giro de UAL1 y su esqueleto de 65 huesos.
	ok = ok and absf(absf(slot.model.rotation.y) - PI) < 0.01
	var skeleton: Skeleton3D = slot.model.find_child("Skeleton3D", true, false) as Skeleton3D
	ok = ok and skeleton != null and skeleton.get_bone_count() == 65
	var player: AnimationPlayer = slot.model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	ok = ok and player != null and player.has_animation(&"Idle") and player.has_animation(&"Fixing_Kneeling")
	# La malla trae cuerpo, cabeza y ropa en superficies separadas; el shader
	# de tejido se aplica a la superficie de tela.
	var meshes: Array[Node] = slot.model.find_children("*", "MeshInstance3D", true, false)
	var surfaces: int = 0
	var cloth: bool = false
	for node: Node in meshes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		surfaces += mesh_instance.mesh.get_surface_count()
		for index: int in range(mesh_instance.mesh.get_surface_count()):
			if mesh_instance.get_surface_override_material(index) is ShaderMaterial:
				cloth = true
	ok = ok and surfaces >= 8 and cloth
	world.free()
	return ok


func test_dressed_roles() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var ok: bool = true
	for npc_name: String in EXPECTED_ROLES:
		var npc: NpcActor = world.get_node_or_null("Llacta/NPCs/%s" % npc_name) as NpcActor
		ok = ok and npc != null
		if npc == null:
			continue
		var slot: ModelSlot = npc.get_node_or_null("Body/ModelSlot") as ModelSlot
		ok = ok and slot != null and slot.model != null
		if slot != null:
			var model: Node3D = slot.model
			ok = ok and absf(absf(model.rotation.y) - PI) < 0.01
		if npc_name == "Tejedora":
			# La tejedora es el prototipo completo de Blender: no lleva la
			# capa procedural encima.
			ok = ok and npc.preserve_materials
			ok = ok and npc.find_child("Outfit", true, false) == null
			ok = ok and slot != null and slot.loaded_path == WEAVER_MODEL
			continue
		var outfit: DressedMannequin = _outfit_of(world, npc_name)
		ok = ok and outfit != null and outfit.is_built()
		if outfit == null:
			continue
		ok = ok and outfit.role == EXPECTED_ROLES[npc_name]
		var bones: Array[StringName] = outfit.attached_bones()
		ok = ok and bones.has(&"pelvis") and bones.has(&"spine_02") and bones.has(&"Head")
		if outfit.role == &"curaca" or outfit.role == &"principal" or outfit.role == &"messenger":
			ok = ok and bones.has(&"spine_03")
		# Todos siguen sobre el maniquí UAL1 y miran hacia delante.
		ok = ok and npc.mannequin_skin
		ok = ok and npc.find_child("OutfitSandalL", true, false) != null
		ok = ok and npc.find_child("OutfitSandalR", true, false) != null
		if outfit.role == &"weaver" or outfit.role == &"villager":
			ok = ok and npc.find_child("OutfitLliclla", true, false) != null
		ok = ok and slot != null and slot.loaded_path == MANNEQUIN_PATH
	# El curaca lleva manto y el mensajero, q'ipi.
	var curaca: NpcActor = world.get_node_or_null("Llacta/NPCs/Curaca") as NpcActor
	var messenger: NpcActor = world.get_node_or_null("Llacta/NPCs/Mensajero") as NpcActor
	ok = ok and curaca != null and curaca.find_child("OutfitCape", true, false) != null
	ok = ok and messenger != null and messenger.find_child("OutfitQipi", true, false) != null
	# Los vecinos usan variantes distintas.
	var second: DressedMannequin = _outfit_of(world, "Habitante2")
	var third: DressedMannequin = _outfit_of(world, "Habitante3")
	ok = ok and second != null and second.variant == 1
	ok = ok and third != null and third.variant == 2
	world.free()
	return ok
