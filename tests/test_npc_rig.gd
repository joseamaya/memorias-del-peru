extends RefCounted
## Comprueba los personajes con esqueleto (ADR-0015, ADR-0016): cada modelo
## trae su esqueleto de MakeHuman, sus animaciones en bucle y su ritmo, la tejedora teje arrodillada (la
## cadera baja) junto al telar, el mensajero corre a la velocidad de su animación y la cabeza puede
## girar hacia el jugador.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const ACTORS: Array[String] = ["Tejedora", "Agricultor", "Mensajero", "Curaca", "Principal1", "Principal2", "Habitante1", "Habitante2", "Habitante3"]
const BASE_ANIMATIONS: Array[StringName] = [&"idle", &"walk", &"run", &"talk", &"tired"]
const BONE_COUNT: int = 31


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
		for animation_name: StringName in BASE_ANIMATIONS:
			ok = ok and player.has_animation(animation_name)
			ok = ok and player.get_animation(animation_name).loop_mode == Animation.LOOP_LINEAR
		var skeletons: Array[Node] = actor.find_children("*", "Skeleton3D", true, false)
		ok = ok and skeletons.size() == 1 and (skeletons[0] as Skeleton3D).get_bone_count() == BONE_COUNT
		ok = ok and actor.look_modifier().bone_name == "Head"
		# Ritmo propio de la captura (extras del glTF), en valores razonables.
		ok = ok and actor.cycle_speed(false) > 0.8 and actor.cycle_speed(false) < 1.6
		ok = ok and actor.cycle_speed(true) > 2.0 and actor.cycle_speed(true) < 4.0
		# Ropa con el material del proyecto.
		var cloth: int = 0
		for node: Node in actor.find_children("*", "MeshInstance3D", true, false):
			var mesh_instance: MeshInstance3D = node as MeshInstance3D
			for surface: int in range(mesh_instance.get_surface_override_material_count()):
				if mesh_instance.get_surface_override_material(surface) == SurfaceMaterials.cloth_material():
					cloth += 1
		ok = ok and cloth >= 1

	# Tejedora: teje arrodillada, con la cabeza por debajo de un metro, en el
	# extremo del telar y mirando a lo largo de él.
	var weaver: NpcActor = world.get_node("Llacta/NPCs/Tejedora") as NpcActor
	var loom: Node3D = world.get_node_or_null("Llacta/LoomSlot") as Node3D
	ok = ok and loom != null and weaver.current_animation() == &"weave"
	if loom != null and weaver.is_animated():
		# La primera llamada arranca la animación; la segunda la aplica.
		weaver.animation_player().advance(0.05)
		weaver.animation_player().advance(0.6)
		var skeleton: Skeleton3D = weaver.find_children("*", "Skeleton3D", true, false)[0] as Skeleton3D
		var hips: int = skeleton.find_bone("Hips")
		# La cadera baja bastante respecto a su altura de pie.
		ok = ok and skeleton.get_bone_pose_position(hips).length() < 0.6 * skeleton.get_bone_rest(hips).origin.length()
		ok = ok and weaver.flat_distance_to(loom.global_position) < 0.6
		var along: Vector3 = loom.global_transform.basis.z
		ok = ok and (-weaver.global_transform.basis.z).dot(along) > 0.95
	var farmer: NpcActor = world.get_node("Llacta/NPCs/Agricultor") as NpcActor
	ok = ok and farmer.animation_player().has_animation(&"work") and farmer.beat_time(&"work") > 0.0

	# El mensajero corre: animación de carrera a la velocidad del desplazamiento.
	var messenger: NpcActor = world.get_node("Llacta/NPCs/Mensajero") as NpcActor
	messenger.walk_to(messenger.global_position + Vector3(0.0, 0.0, 10.0))
	ok = ok and messenger.current_animation() == &"run"
	ok = ok and absf(messenger.animation_speed() - messenger.walk_speed / messenger.cycle_speed(true)) < 0.01
	messenger.stop()
	ok = ok and messenger.current_animation() == &"idle"
	# Un gesto temporal vuelve solo al reposo.
	messenger.perform(&"tired", 0.5)
	ok = ok and messenger.current_animation() == &"tired"
	messenger._process(0.6)
	ok = ok and messenger.current_animation() == &"idle"

	# La comitiva camina (ya no a 3,2 m/s, que solo cabía corriendo).
	var curaca: NpcActor = world.get_node("Llacta/NPCs/Curaca") as NpcActor
	ok = ok and curaca.walk_speed < NpcActor.RUN_SPEED_THRESHOLD
	world.free()
	return ok
