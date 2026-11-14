extends RefCounted
## Comprueba los personajes del acto I con los modelos MakeHuman/Rocketbox:
## esqueleto humanoide, animaciones base, mirada y ritmo de trabajo. UAL1
## queda para los actos II y III y como respaldo.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const ACTORS: Array[String] = ["Tejedora", "Agricultor", "Mensajero", "Curaca", "Principal1", "Principal2", "Habitante1", "Habitante2", "Habitante3"]
const COMMON_CLIPS: Array[StringName] = [&"idle", &"walk", &"run", &"talk"]


func test_npc_rig() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var ok: bool = true
	for actor_name: String in ACTORS:
		var actor: NpcActor = world.get_node_or_null("Llacta/NPCs/%s" % actor_name) as NpcActor
		ok = ok and actor != null and actor.is_animated() and actor.look_modifier() != null
		if actor == null or not actor.is_animated():
			continue
		var player: AnimationPlayer = actor.animation_player()
		for clip: StringName in COMMON_CLIPS:
			ok = ok and player.has_animation(clip)
		var skeletons: Array[Node] = actor.find_children("*", "Skeleton3D", true, false)
		var bones: int = (skeletons[0] as Skeleton3D).get_bone_count() if skeletons.size() == 1 else 0
		ok = ok and skeletons.size() == 1 and bones > 20
		ok = ok and (actor.look_modifier().bone_name == "Head" or actor.look_modifier().bone_name == "head")
		ok = ok and actor.cycle_speed(false) > 0.8 and actor.cycle_speed(false) < 1.6
		ok = ok and actor.cycle_speed(true) > 1.5 and actor.cycle_speed(true) < 4.0

	# La tejedora sigue arrodillada junto al telar y el agricultor conserva su
	# golpe de trabajo, aunque el maniquí no traiga el ritmo del modelo propio.
	var weaver: NpcActor = world.get_node("Llacta/NPCs/Tejedora") as NpcActor
	var loom: Node3D = world.get_node_or_null("Llacta/LoomSlot") as Node3D
	ok = ok and weaver.current_animation() == &"weave"
	if loom != null:
		ok = ok and weaver.flat_distance_to(loom.global_position) < 0.6
		var along: Vector3 = loom.global_transform.basis.z
		ok = ok and (-weaver.global_transform.basis.z).dot(along) > 0.95
	var farmer: NpcActor = world.get_node("Llacta/NPCs/Agricultor") as NpcActor
	ok = ok and farmer.current_animation() == &"work" and farmer.beat_time(&"work") > 0.0

	# El mensajero corre con la animación de carrera a la velocidad del
	# desplazamiento y vuelve al reposo al detenerse.
	var messenger: NpcActor = world.get_node("Llacta/NPCs/Mensajero") as NpcActor
	messenger.walk_to(messenger.global_position + Vector3(0.0, 0.0, 30.0))
	ok = ok and messenger.current_animation() == &"run"
	messenger.advance(1.0 / 30.0)
	ok = ok and messenger.current_speed() < 0.5
	for i: int in range(60):
		messenger.advance(1.0 / 30.0)
	ok = ok and absf(messenger.current_speed() - messenger.walk_speed) < 0.05
	ok = ok and absf(messenger.animation_speed() - messenger.walk_speed / messenger.cycle_speed(true)) < 0.01
	messenger.stop()
	ok = ok and messenger.current_animation() == &"idle"
	messenger.perform(&"tired", 0.5)
	ok = ok and messenger.current_animation() == &"tired"
	messenger._process(0.6)
	ok = ok and messenger.current_animation() == &"idle"

	# La comitiva camina, no corre.
	var curaca: NpcActor = world.get_node("Llacta/NPCs/Curaca") as NpcActor
	ok = ok and curaca.walk_speed < NpcActor.RUN_SPEED_THRESHOLD
	world.free()
	return ok
