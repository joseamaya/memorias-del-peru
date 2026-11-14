extends RefCounted
## Acto I: los nueve personajes usan los modelos MakeHuman/Rocketbox ya
## versionados (CC0/MIT), con su esqueleto, su ropa y sus animaciones. UAL1
## queda para los actos II y III y como respaldo.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const MODEL_DIR: String = "res://campaigns/01_pachacutec/assets/models/"
const MODELS: Dictionary[String, String] = {
	"Tejedora": "pch_npc_weaver.glb",
	"Agricultor": "pch_npc_farmer.glb",
	"Mensajero": "pch_npc_messenger.glb",
	"Curaca": "pch_npc_curaca.glb",
	"Principal1": "pch_npc_principal.glb",
	"Principal2": "pch_npc_principal.glb",
	"Habitante1": "pch_npc_villager.glb",
	"Habitante2": "pch_npc_villager_b.glb",
	"Habitante3": "pch_npc_villager_c.glb",
}
const COMMON_CLIPS: Array[StringName] = [&"idle", &"walk", &"run", &"talk"]


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


func _actor(world: Node, actor_name: String) -> NpcActor:
	return world.get_node_or_null("Llacta/NPCs/%s" % actor_name) as NpcActor


func _slot(actor: NpcActor) -> ModelSlot:
	if actor == null:
		return null
	return actor.get_node_or_null("Body/ModelSlot") as ModelSlot


func test_character_weaver() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var weaver: NpcActor = _actor(world, "Tejedora")
	var slot: ModelSlot = _slot(weaver)
	var ok: bool = weaver != null and slot != null and slot.model != null
	if not ok:
		world.free()
		return false
	ok = ok and slot.loaded_path == MODEL_DIR + MODELS["Tejedora"]
	ok = ok and weaver.preserve_materials and not weaver.mannequin_skin
	ok = ok and weaver.current_animation() == &"weave"
	ok = ok and weaver.find_child("Outfit", true, false) == null
	# El modelo MakeHuman mira hacia -Z: no se le aplica el giro de UAL1.
	ok = ok and absf(slot.model.rotation.y) < 0.01
	var player: AnimationPlayer = weaver.animation_player()
	ok = ok and player != null
	if player != null:
		for clip: StringName in COMMON_CLIPS:
			ok = ok and player.has_animation(clip)
		ok = ok and player.has_animation(&"weave")
	var skeleton: Skeleton3D = slot.model.find_child("Skeleton3D", true, false) as Skeleton3D
	ok = ok and skeleton != null and skeleton.get_bone_count() > 20
	# Cuerpo, ropa y cabeza con sus materiales; la ropa usa el shader de tela.
	var meshes: Array[Node] = slot.model.find_children("*", "MeshInstance3D", true, false)
	ok = ok and meshes.size() >= 3
	var cloth: bool = false
	var skin: bool = false
	for node: Node in meshes:
		var mesh_instance: MeshInstance3D = node as MeshInstance3D
		if mesh_instance.mesh == null:
			continue
		for index: int in range(mesh_instance.mesh.get_surface_count()):
			var material: Material = mesh_instance.mesh.surface_get_material(index)
			if material == null:
				continue
			if material.resource_name == "pch_cloth":
				cloth = true
			if material.resource_name == "Human.body":
				skin = true
	ok = ok and cloth and skin
	world.free()
	return ok


func test_character_roles() -> bool:
	var world: Node = _spawn_world()
	if world == null:
		return false
	var ok: bool = true
	for actor_name: String in MODELS:
		var actor: NpcActor = _actor(world, actor_name)
		var slot: ModelSlot = _slot(actor)
		ok = ok and actor != null and slot != null and slot.model != null
		if actor == null or slot == null:
			continue
		ok = ok and slot.loaded_path == MODEL_DIR + MODELS[actor_name]
		ok = ok and actor.preserve_materials and not actor.mannequin_skin
		ok = ok and actor.find_child("Outfit", true, false) == null
		ok = ok and absf(slot.model.rotation.y) < 0.01
		var player: AnimationPlayer = actor.animation_player()
		ok = ok and player != null
		if player != null:
			for clip: StringName in COMMON_CLIPS:
				ok = ok and player.has_animation(clip)
			if actor_name == "Tejedora":
				ok = ok and player.has_animation(&"weave")
				ok = ok and actor.current_animation() == &"weave"
			elif actor_name == "Agricultor":
				ok = ok and player.has_animation(&"work")
				ok = ok and actor.current_animation() == &"work"
			elif actor_name == "Principal2":
				ok = ok and (actor.current_animation() == &"idle" or actor.current_animation() == &"idle_b")
			else:
				ok = ok and (actor.current_animation() == &"idle" or actor.current_animation() == &"idle_b")
		var skeleton: Skeleton3D = slot.model.find_child("Skeleton3D", true, false) as Skeleton3D
		ok = ok and skeleton != null and skeleton.get_bone_count() > 20
	world.free()
	return ok
