extends RefCounted
## Comprueba el maniquí vestido del acto I (ADR-0042): los nueve personajes
## llevan ropa y rostro anclados a los huesos del UAL1, cada uno con su rol, el
## maniquí sigue animado y mira hacia delante, y no queda ningún modelo viejo.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MANNEQUIN_PATH: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"
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
	var outfit: DressedMannequin = _outfit_of(world, "Tejedora")
	var ok: bool = weaver != null and outfit != null and outfit.is_built()
	if not ok:
		world.free()
		return false
	var bones: Array[StringName] = outfit.attached_bones()
	ok = ok and bones.has(&"pelvis") and bones.has(&"spine_02") and bones.has(&"Head")
	# Ropa (shader de tejido o textil con franjas) y rostro/pelo.
	var fabric: int = 0
	var textile: int = 0
	var skin: int = 0
	for node: Node in weaver.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.material_override is ShaderMaterial:
			fabric += 1
		elif mesh_instance.material_override is StandardMaterial3D:
			var standard: StandardMaterial3D = mesh_instance.material_override as StandardMaterial3D
			if standard.albedo_texture != null:
				textile += 1
			else:
				skin += 1
	ok = ok and fabric >= 5 and textile >= 4 and skin >= 3
	# Lliclla en dos paños y sandalias.
	ok = ok and weaver.find_child("OutfitLliclla", true, false) != null
	ok = ok and weaver.find_child("OutfitSandalL", true, false) != null
	ok = ok and weaver.find_child("OutfitSandalR", true, false) != null
	# El maniquí conserva su animación de tejer y su piel.
	ok = ok and weaver.current_animation() == &"weave"
	ok = ok and weaver.mannequin_skin
	# UAL1 mira a +Z; el modelo se gira para que el actor mire a -Z.
	var slot: ModelSlot = weaver.get_node_or_null("Body/ModelSlot") as ModelSlot
	ok = ok and slot != null and slot.loaded_path == MANNEQUIN_PATH
	if slot != null:
		var model: Node3D = slot.model
		ok = ok and model != null and absf(absf(model.rotation.y) - PI) < 0.01
	world.free()
	return ok


func test_dressed_roles() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var ok: bool = true
	for npc_name: String in EXPECTED_ROLES:
		var npc: NpcActor = world.get_node_or_null("Llacta/NPCs/%s" % npc_name) as NpcActor
		var outfit: DressedMannequin = _outfit_of(world, npc_name)
		ok = ok and npc != null and outfit != null and outfit.is_built()
		if npc == null or outfit == null:
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
		var slot: ModelSlot = npc.get_node_or_null("Body/ModelSlot") as ModelSlot
		ok = ok and slot != null and slot.loaded_path == MANNEQUIN_PATH
		if slot != null:
			var model: Node3D = slot.model
			ok = ok and model != null and absf(absf(model.rotation.y) - PI) < 0.01
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
