extends RefCounted
## Comprueba el prototipo de maniquí vestido (ADR-0042): la tejedora lleva ropa
## y rostro anclados a los huesos del UAL1, el maniquí sigue animado, mira hacia
## delante y ningún personaje del acto I carga los modelos viejos.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MANNEQUIN_PATH: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"


func test_dressed_weaver() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var weaver: NpcActor = world.get_node_or_null("Llacta/NPCs/Tejedora") as NpcActor
	var outfit: DressedMannequin = weaver.get_node_or_null("Outfit") as DressedMannequin
	var ok: bool = weaver != null and outfit != null and outfit.is_built()
	if not ok:
		world.free()
		return false
	var bones: Array[StringName] = outfit.attached_bones()
	ok = ok and bones.has(&"pelvis") and bones.has(&"spine_02") and bones.has(&"Head")
	# Ropa (shader de tejido) y rostro/pelo (materiales planos).
	var fabric: int = 0
	var skin: int = 0
	for node: Node in weaver.find_children("*", "MeshInstance3D", true, false):
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.material_override is ShaderMaterial:
			fabric += 1
		elif mesh_instance.material_override is StandardMaterial3D:
			skin += 1
	ok = ok and fabric >= 5 and skin >= 3
	# El maniquí conserva su animación de tejer y su piel.
	ok = ok and weaver.current_animation() == &"weave"
	ok = ok and weaver.mannequin_skin
	# UAL1 mira a +Z; el modelo se gira para que el actor mire a -Z.
	var slot: ModelSlot = weaver.get_node_or_null("Body/ModelSlot") as ModelSlot
	ok = ok and slot != null and slot.loaded_path == MANNEQUIN_PATH
	var model: Node3D = slot.model if slot != null else null
	ok = ok and model != null and absf(absf(model.rotation.y) - PI) < 0.01
	# Ningún personaje del acto I carga los modelos viejos.
	var npcs: Node = world.get_node("Llacta/NPCs")
	for npc: Node in npcs.get_children():
		var each: ModelSlot = npc.get_node_or_null("Body/ModelSlot") as ModelSlot
		if each != null and not each.loaded_path.is_empty():
			ok = ok and each.loaded_path == MANNEQUIN_PATH
	# Solo la tejedora lleva el prototipo de vestuario.
	for npc: Node in npcs.get_children():
		var has_outfit: bool = npc.get_node_or_null("Outfit") != null
		ok = ok and has_outfit == (npc.name == "Tejedora")
	world.free()
	return ok
