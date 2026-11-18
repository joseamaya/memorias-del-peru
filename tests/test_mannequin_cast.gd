extends RefCounted
## Pruebas del elenco de maniquíes ya integrado en el juego.
##
## Cubren el actor de la llacta, los clips lógicos del UAL1/UAL2, la fusión del
## atuendo, el LOD de multitud y el chanca con su porra.

const UAL1: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"
const NPC_SCENE: String = "res://campaigns/01_pachacutec/scenes/npcs/npc_actor.tscn"
const LLACTA: String = "res://campaigns/01_pachacutec/scenes/world/llacta.tscn"


func test_mannequin_npc_actor() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var packed: PackedScene = load(NPC_SCENE) as PackedScene
	var actor: NpcActor = packed.instantiate() as NpcActor
	tree.root.add_child(actor)
	actor.target_height = 1.65
	var model: Node3D = OutfitMannequin.attach_look(
		actor, MannequinLooks.for_role("Curaca"))
	actor.set_model(model)
	var ok: bool = model != null and actor.is_animated()
	ok = ok and actor.current_animation() == &"idle"
	ok = ok and actor.look_modifier() != null
	ok = ok and actor.spring_simulator() == null
	ok = ok and actor.character_face() == null
	ok = ok and actor.focus_point().y > 1.0
	ok = ok and CharacterOutfit.piece_count(model) == MannequinLooks.curaca().parts.size()
	actor.free()
	return ok


func test_mannequin_clips() -> bool:
	var packed: PackedScene = load(UAL1) as PackedScene
	var model: Node3D = packed.instantiate() as Node3D
	var player: AnimationPlayer = QuaterniusClips.ensure_player(model)
	var ok: bool = player != null
	for clip: StringName in [&"Idle", &"Walk", &"Jog_Fwd", &"Idle_Talking", &"Crouch_Idle",
			&"Fixing_Kneeling", &"Sword_Attack", &"Hit_Chest", &"Death01"]:
		ok = ok and player.has_animation(clip)
	for clip: StringName in [&"idle", &"walk", &"run", &"talk", &"work", &"weave",
			&"tired", &"attack", &"hit", &"death"]:
		ok = ok and player.has_animation(clip)
	# UAL2 sustituye el trabajo y la reacción al golpe.
	ok = ok and player.get_animation(&"work").length > 2.7
	ok = ok and player.get_animation(&"hit").length > 0.8
	model.free()
	return ok


func test_mannequin_outfit_merge() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var holder: Node3D = Node3D.new()
	tree.root.add_child(holder)
	var model: Node3D = OutfitMannequin.attach_look(
		holder, MannequinLooks.for_role("Curaca"))
	var look: CharacterLook = MannequinLooks.curaca()
	var ok: bool = model != null
	ok = ok and CharacterOutfit.piece_count(model) == look.parts.size()
	var meshes: Array[Node] = model.find_children("Outfit_*", "MeshInstance3D", true, false)
	ok = ok and meshes.size() == 3
	for node: Node in meshes:
		var mesh: MeshInstance3D = node as MeshInstance3D
		ok = ok and mesh.mesh != null and mesh.mesh.get_surface_count() == 1
		var material: StandardMaterial3D = mesh.mesh.surface_get_material(0) as StandardMaterial3D
		ok = ok and material != null and material.vertex_color_use_as_albedo
		if mesh.name == "Outfit_Head":
			ok = ok and mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
		else:
			ok = ok and mesh.cast_shadow == GeometryInstance3D.SHADOW_CASTING_SETTING_ON
	holder.free()
	return ok


func test_mannequin_crowd_lod() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var full: CharacterLook = MannequinLooks.for_role("Sisa")
	var crowd: CharacterLook = MannequinLooks.crowd_from(full)
	var ok: bool = crowd.parts.size() < full.parts.size()
	ok = ok and not _has_part(crowd, "Tupu") and not _has_part(crowd, "Chuspa")
	ok = ok and _has_part(crowd, "LlicllaFront") and _has_part(crowd, "HairBack")
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "CrowdMannequinTest"
	visual.look = full
	visual.crowd = true
	tree.root.add_child(visual)
	var model: Node3D = visual.model()
	ok = ok and model != null
	if model != null:
		ok = ok and CharacterOutfit.piece_count(model) == crowd.parts.size()
		ok = ok and visual.spring_simulator() == null
		ok = ok and visual.character_face() == null
	visual.free()
	return ok


func test_mannequin_chanca_porra() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var visual: CharacterModelVisual = CharacterModelVisual.new()
	visual.name = "ChancaMannequinTest"
	visual.look = MannequinLooks.for_role("Chanca")
	visual.porra = true
	visual.target_height = 1.67
	tree.root.add_child(visual)
	var ok: bool = visual.model() != null
	ok = ok and visual.porra_pivot() != null
	ok = ok and visual.clip_length(&"death") > 0.0
	visual.play(&"attack")
	ok = ok and visual.current_animation() == &"attack"
	visual.free()
	return ok


func test_llacta_mannequin_cast() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	var state: Node = tree.root.get_node("CampaignState")
	state.call("clear")
	state.call("set_flag", &"intro_vista")
	var packed: PackedScene = load(LLACTA) as PackedScene
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var curaca: NpcActor = world.get_node_or_null("Llacta/NPCs/Curaca") as NpcActor
	var weaver: NpcActor = world.get_node_or_null("Llacta/NPCs/Tejedora") as NpcActor
	var farmer: NpcActor = world.get_node_or_null("Llacta/NPCs/Agricultor") as NpcActor
	var hijo: NpcActor = world.get_node_or_null("Llacta/NPCs/HijoPuma") as NpcActor
	var ok: bool = curaca != null and curaca.find_child("MannequinModel", true, false) != null
	ok = ok and curaca.current_animation() == &"idle"
	ok = ok and weaver != null and weaver.current_animation() == &"weave"
	ok = ok and farmer != null and farmer.current_animation() == &"work"
	ok = ok and hijo != null and is_equal_approx(hijo.target_height, 1.20)
	if curaca != null:
		var model: Node3D = curaca.find_child("MannequinModel", true, false) as Node3D
		ok = ok and model != null
		ok = ok and CharacterOutfit.piece_count(model) == MannequinLooks.curaca().parts.size()
	world.free()
	return ok


static func _has_part(look: CharacterLook, part_name: String) -> bool:
	for part: LookPart in look.parts:
		if part.name == part_name:
			return true
	return false
