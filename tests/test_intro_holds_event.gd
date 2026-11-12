extends RefCounted
## Comprueba la introducción del slice en el mundo (ADR-0023): el reloj del
## mensajero y el jugador esperan a que termine, y las tarjetas no adelantan la
## noticia que mide el cuestionario.

const WORLD_PATH: String = "res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn"
## Palabras que responderían las preguntas 1 y 2 del cuestionario (alcance §9.3).
const SPOILERS: Array[String] = ["chanca", "heredero", "cusi yupanqui", "amenaza", "pachac"]


func _spawn_world(mode: MundoBase.IntroMode) -> MundoBase:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(WORLD_PATH) as PackedScene
	if packed == null:
		return null
	var world: MundoBase = packed.instantiate() as MundoBase
	if world == null:
		return null
	world.intro_mode = mode
	tree.root.add_child(world)
	return world


func test_intro_holds_event_clock() -> bool:
	var world: MundoBase = _spawn_world(MundoBase.IntroMode.ALWAYS)
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var player: Node = world.get_node_or_null("PlayerFPS")
	var hud: PlayerHud = world.get_node_or_null("UILayer/HUD") as PlayerHud
	var intro: IntroCards = world.get_intro()
	if event == null or player == null or hud == null or intro == null:
		world.free()
		return false
	# Durante la introducción: sin reloj, sin apertura y sin control.
	var ok: bool = world.is_intro_playing() and not event.has_begun() and not event.is_processing()
	# La primera tarjeta es la nota histórica (ADR-0024).
	ok = ok and intro.current_text() == tr("PCH_INTRO_NOTE") and MundoBase.INTRO_KEYS.size() == 4
	ok = ok and not hud.is_showing_hint()
	ok = ok and not hud.is_showing_subtitle()
	# Tomas y mapa (ADR-0025): la cámara de la introducción es la activa, la
	# primera tarjeta es negra y el mapa es la capa de la tarjeta del Cusco.
	var director: IntroDirector = world.get_intro_director()
	var player_camera: Camera3D = world.get_node_or_null("PlayerFPS/Head/Camera3D") as Camera3D
	ok = ok and director != null and player_camera != null
	if not ok:
		world.free()
		return false
	ok = ok and director.get_camera().is_current() and not player_camera.is_current()
	ok = ok and intro.is_card_opaque(0) and not intro.is_card_opaque(MundoBase.INTRO_SHOT_ANDES)
	ok = ok and intro.get_node_or_null("Overlays") != null and intro.get_node("Overlays").get_child(0) is IntroMap
	ok = ok and player.process_mode == Node.PROCESS_MODE_DISABLED
	# Se recorren las tarjetas hasta el final.
	var guard: int = 0
	while intro.is_playing() and guard < 2000:
		intro.advance(0.1)
		guard += 1
	ok = ok and not world.is_intro_playing()
	ok = ok and event.has_begun() and event.is_processing() and event.phase == MessengerEvent.Phase.IDLE
	ok = ok and hud.is_showing_subtitle()
	ok = ok and player.process_mode == Node.PROCESS_MODE_INHERIT
	# Los controles aparecen al tomar el control (ADR-0024).
	ok = ok and hud.is_showing_hint()
	# La última toma termina en los ojos del jugador y su cámara vuelve a mandar.
	ok = ok and player_camera.is_current() and not director.get_camera().is_current()
	ok = ok and director.get_camera().global_transform.origin.distance_to(player_camera.global_transform.origin) < 0.01
	world.free()
	return ok


func test_intro_skipped_when_loaded_directly() -> bool:
	# En AUTO, un mundo cargado por una prueba (no es la escena principal) no
	# muestra la introducción y el reloj arranca como antes.
	var world: MundoBase = _spawn_world(MundoBase.IntroMode.AUTO)
	if world == null:
		return false
	var event: MessengerEvent = world.get_node_or_null("EventController") as MessengerEvent
	var ok: bool = event != null and not world.is_intro_playing() and world.get_intro() == null
	ok = ok and event.has_begun()
	world.free()
	return ok


func test_intro_texts_do_not_spoil() -> bool:
	var ok: bool = true
	for key: StringName in MundoBase.INTRO_KEYS:
		var text: String = TranslationServer.translate(key).to_lower()
		# La clave debe tener traducción.
		ok = ok and text != String(key).to_lower() and not text.is_empty()
		for word: String in SPOILERS:
			ok = ok and not text.contains(word)
	return ok
