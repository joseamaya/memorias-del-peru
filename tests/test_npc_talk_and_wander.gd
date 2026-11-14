extends RefCounted
## Comprueba los cambios del primer piloto (ADR-0012, ADR-0013): sin el rótulo
## de lugar, que la introducción sustituye (ADR-0023), el vecino que recibe al jugador en el camino sur, «Hablar» con seis personajes solo antes de la noticia, la frase en
## el HUD con el personaje girado hacia el jugador, y el paseo de los vecinos,
## que se detiene cuando llega el mensajero. Con el esqueleto (ADR-0015): la
## tejedora teje arrodillada y solo gira la cabeza, el agricultor deja el
## trabajo para hablar y los vecinos caminan con su animación y sus pasos.

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
	ok = ok and not title.visible
	ok = ok and event.arrival_delay <= 360.0 and event.arrival_delay + event.arrival_grace <= 380.0

	# El vecino que recibe espera junto al camino sur y saluda al acercarse.
	var greeter: NpcActor = world.get_node("Llacta/NPCs/Habitante3") as NpcActor
	ok = ok and greeter.global_position.distance_to(Vector3(3.2, 0.0, 12.0)) < 0.01 and not event.has_greeted()
	player.global_position = Vector3(0.0, 0.05, 40.0)
	event.step(0.1)
	ok = ok and not event.has_greeted()
	player.global_position = Vector3(0.0, 0.05, 20.0)
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

	# Hablar con la tejedora: su frase va al HUD; sigue de pie junto al telar y
	# solo gira la cabeza hacia el jugador, que está delante.
	hud.clear_subtitle()
	var weaver: NpcActor = world.get_node("Llacta/NPCs/Tejedora") as NpcActor
	var weaver_forward: Vector3 = -weaver.global_transform.basis.z
	player.global_position = weaver.global_position + weaver_forward * 2.0 + weaver_forward.cross(Vector3.UP)
	talks[0].interact(player)
	# La tejedora abre una conversación con opciones (Fase 6).
	ok = ok and hud.is_dialogue_open()
	ok = ok and hud.get_dialogue_panel().get_text() == tr("PCH_TALK_WEAVER")
	ok = ok and player.process_mode == Node.PROCESS_MODE_DISABLED
	ok = ok and weaver.is_animated() and weaver.current_animation() == &"idle"
	ok = ok and (-weaver.global_transform.basis.z).is_equal_approx(weaver_forward)
	ok = ok and weaver.wants_to_look() and weaver.look_modifier() != null
	# Salir de la conversación por la segunda opción.
	hud.get_dialogue_panel().choice_selected.emit(1)
	ok = ok and not hud.is_dialogue_open()
	ok = ok and player.process_mode == Node.PROCESS_MODE_INHERIT

	# Hablar con el agricultor: se gira hacia el jugador y deja la chaquitaclla.
	var farmer: NpcActor = world.get_node("Llacta/NPCs/Agricultor") as NpcActor
	ok = ok and farmer.current_animation() == &"work"
	player.global_position = farmer.global_position + Vector3(2.0, 0.0, 0.0)
	talks[1].interact(player)
	# El agricultor también tiene conversación (Fase 6).
	ok = ok and hud.is_dialogue_open()
	ok = ok and hud.get_dialogue_panel().get_text() == tr("PCH_TALK_FARMER")
	hud.get_dialogue_panel().choice_selected.emit(1)
	ok = ok and not hud.is_dialogue_open()
	# Se vuelve poco a poco, como una persona (no de golpe).
	farmer._process(1.0)
	var to_player: Vector3 = (player.global_position - farmer.global_position).normalized()
	ok = ok and (-farmer.global_transform.basis.z).dot(to_player) > 0.9
	ok = ok and farmer.current_animation() == &"idle"

	# Paseo: los vecinos se mueven antes de la noticia.
	var neighbor: NpcActor = world.get_node("Llacta/NPCs/Habitante1") as NpcActor
	var start: Vector3 = neighbor.global_position
	var steps: Array[int] = [0]
	var walked: bool = false
	neighbor.stepped.connect(func() -> void: steps[0] += 1)
	ok = ok and neighbor.is_animated()
	for i: int in range(40):
		event.step(0.25)
		if neighbor.moving and neighbor.current_animation() == &"walk" and neighbor.animation_speed() > 0.9:
			walked = true
	ok = ok and neighbor.global_position.distance_to(start) > 1.0
	# Camina con la animación a la velocidad del paso, y da pasos (ADR-0015).
	ok = ok and walked and steps[0] >= 3
	ok = ok and event.phase == MessengerEvent.Phase.IDLE

	# Hablar con un vecino lo detiene un rato.
	var talk_one: NpcTalk = world.get_node("Llacta/NPCs/Habitante1/Talk") as NpcTalk
	talk_one.interact(player)
	var held_at: Vector3 = neighbor.global_position
	event.step(2.0)
	ok = ok and neighbor.global_position.distance_to(held_at) < 0.01
	ok = ok and neighbor.current_animation() == &"talk"

	# Al llegar el mensajero, nadie más habla; los vecinos dejan el paseo y se
	# acercan al punto donde se forma el grupo.
	event.start()
	ok = ok and event.phase == MessengerEvent.Phase.ARRIVAL
	for talk: NpcTalk in talks:
		ok = ok and not talk.is_available()
	for actor_name: String in ["Habitante1", "Habitante2", "Habitante3"]:
		var actor: NpcActor = world.get_node("Llacta/NPCs/%s" % actor_name) as NpcActor
		ok = ok and actor.moving
	world.free()
	return ok
