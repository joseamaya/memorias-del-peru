extends RefCounted
## Comprueba los cambios del primer piloto (ADR-0012, ADR-0013): el rótulo de
## lugar al empezar, el vecino que recibe al jugador en el camino sur, «Hablar» con seis personajes solo antes de la noticia, la frase en
## el HUD con el personaje girado hacia el jugador, y el paseo de los vecinos,
## que se detiene cuando llega el mensajero, con las piernas balanceándose.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
const TALKERS: Array[String] = ["Tejedora", "Agricultor", "Curaca", "Habitante1", "Habitante2", "Habitante3"]
const INTERACTABLE_LAYER: int = 4


func test_npc_talk_and_wander() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load(WORLD_PATH) as PackedScene).instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node3D = world.get_node_or_null("PlayerFPS") as Node3D
	var title: Label = world.get_node_or_null("UILayer/HUD/TitleLabel") as Label
	var subtitle: Label = world.get_node_or_null("UILayer/HUD/SubtitleLabel") as Label
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var ok: bool = event != null and player != null and title != null and subtitle != null and hud != null
	if not ok:
		world.free()
		return false
	ok = ok and title.visible and not title.text.begins_with("PCH_")
	ok = ok and event.arrival_delay <= 75.0 and event.arrival_delay + event.arrival_grace <= 150.0

	# El vecino que recibe espera junto al camino sur y saluda al acercarse.
	var greeter: NpcActor = world.get_node("Llacta/NPCs/Habitante3") as NpcActor
	ok = ok and greeter.global_position.distance_to(Vector3(3.2, 0.0, 18.0)) < 0.01 and not event.has_greeted()
	player.global_position = Vector3(0.0, 0.05, 40.0)
	event.step(0.1)
	ok = ok and not event.has_greeted()
	player.global_position = Vector3(0.0, 0.05, 24.0)
	event.step(0.1)
	ok = ok and event.has_greeted()

	# «Hablar»: seis personajes, en la capa de interactuables y disponibles.
	var talks: Array[NpcTalk] = []
	for actor_name: String in TALKERS:
		var talk: NpcTalk = world.get_node_or_null("Llacta/NPCs/%s/Talk" % actor_name) as NpcTalk
		ok = ok and talk != null
		if talk == null:
			continue
		var body: StaticBody3D = talk as Object as StaticBody3D
		ok = ok and body != null and body.collision_layer == INTERACTABLE_LAYER
		ok = ok and talk.is_available() and talk.event == event
		ok = ok and not tr(String(talk.line_key)).begins_with("PCH_")
		talks.append(talk)
	if talks.size() != TALKERS.size():
		world.free()
		return false

	# Hablar con la tejedora: su frase va al HUD y se gira hacia el jugador.
	hud.clear_subtitle()
	var weaver: NpcActor = world.get_node("Llacta/NPCs/Tejedora") as NpcActor
	player.global_position = weaver.global_position + Vector3(2.0, 0.0, 0.0)
	talks[0].interact(player)
	ok = ok and subtitle.visible and subtitle.text == tr("PCH_TALK_WEAVER")
	var to_player: Vector3 = (player.global_position - weaver.global_position).normalized()
	var forward: Vector3 = -weaver.global_transform.basis.z
	ok = ok and forward.dot(to_player) > 0.9

	# Paseo: los vecinos se mueven antes de la noticia.
	var neighbor: NpcActor = world.get_node("Llacta/NPCs/Habitante1") as NpcActor
	var start: Vector3 = neighbor.global_position
	var max_swing: float = 0.0
	var max_arm: float = 0.0
	ok = ok and neighbor.has_legs()
	for i: int in range(40):
		event.step(0.25)
		max_swing = maxf(max_swing, absf(neighbor.left_leg_angle()))
		max_arm = maxf(max_arm, absf(neighbor.left_arm_angle()))
	ok = ok and neighbor.global_position.distance_to(start) > 1.0
	# Al caminar balancea las piernas (ADR-0013).
	ok = ok and max_swing > 10.0 and max_arm > 7.0
	ok = ok and event.phase == MessengerEvent.Phase.IDLE

	# Hablar con un vecino lo detiene un rato.
	var talk_one: NpcTalk = world.get_node("Llacta/NPCs/Habitante1/Talk") as NpcTalk
	talk_one.interact(player)
	var held_at: Vector3 = neighbor.global_position
	event.step(2.0)
	ok = ok and neighbor.global_position.distance_to(held_at) < 0.01
	ok = ok and is_zero_approx(neighbor.left_leg_angle())

	# Al llegar el mensajero, nadie más habla y los vecinos dejan de pasear.
	event.start()
	ok = ok and event.phase == MessengerEvent.Phase.ARRIVAL
	for talk: NpcTalk in talks:
		ok = ok and not talk.is_available()
	for actor_name: String in ["Habitante1", "Habitante2", "Habitante3"]:
		var actor: NpcActor = world.get_node("Llacta/NPCs/%s" % actor_name) as NpcActor
		ok = ok and not actor.moving
	world.free()
	return ok
