class_name MessengerEvent
extends Node
## Evento de la llegada del mensajero (ADR-0007 y ADR-0009).
##
## El mensajero llega a media mañana: el reloj arranca al empezar la partida y,
## a partir de ahí, el evento espera a que el jugador esté en la plaza o agota
## una espera máxima. El pututu solo responde durante la llamada y el curaca lo
## toca como respaldo, de modo que la experiencia nunca puede quedarse sin
## final. El avance lo impulsa `step(delta)` para poder probarlo sin esperas.

enum Phase { IDLE, ARRIVAL, MESSAGE, CALL, DEPARTURE, DONE }

signal started
signal phase_changed(phase: int)
signal finished
signal subtitle_requested(text_key: StringName, seconds: float)

const KEY_OPENING: StringName = &"PCH_NARR_OPENING"
const KEY_NEWS_FIRST: StringName = &"PCH_NARR_NEWS_1"
const KEY_NEWS_SECOND: StringName = &"PCH_NARR_NEWS_2"
const KEY_CALL: StringName = &"PCH_NARR_CALL"
const KEY_CLOSING_FIRST: StringName = &"PCH_NARR_CLOSING_1"
const KEY_CLOSING_SECOND: StringName = &"PCH_NARR_CLOSING_2"
const KEY_WAIT: StringName = &"PCH_NARR_WAIT"
const KEY_GATHER: StringName = &"PCH_NARR_GATHER"
const KEY_GREET: StringName = &"PCH_NARR_GREET"

const OPENING_SECONDS: float = 6.0
const NEWS_SECONDS: float = 6.0
const NEWS_SECOND_DELAY: float = 6.0
const MESSAGE_DURATION: float = 12.0
## Segundos que el mensajero tarda en recobrar el aliento antes de hablar.
const MESSENGER_BREATH_SECONDS: float = 2.5
const CALL_SECONDS: float = 5.0
const CLOSING_SECONDS: float = 6.0
const CLOSING_SECOND_DELAY: float = 6.0
## Tiempo máximo para que la comitiva salga de la vista; si no llega al
## camino norte, se oculta igual.
const DEPARTURE_TIMEOUT: float = 45.0
## Cierre corto (ADR-0026): el evento termina este tiempo después del segundo
## subtítulo de cierre, aunque la comitiva siga caminando, para que la tarjeta
## de fin llegue sin un vacío tras el pututu.
const CLOSING_HOLD: float = 8.0
## Señal intermedia de la espera (ADR-0012, ADR-0013): a mitad del reloj, un
## texto recuerda que el mensajero aún no llega.
const WAIT_CUE_TIME: float = 45.0
const GATHER_SECONDS: float = 6.0
## Vecino que recibe al jugador en el camino sur (ADR-0013): habla cuando el
## jugador se acerca a esta distancia.
const GREET_DISTANCE: float = 9.0
const GREET_SECONDS: float = 6.0
const GREET_PAUSE: float = 3.0
const WAIT_SECONDS: float = 6.0
## Pausa de los vecinos en cada punto de su paseo, antes de la noticia.
const WANDER_PAUSE: float = 4.0
const WANDER_PAUSE_STAGGER: float = 1.5

## Disposición de la reunión (ver _meeting_point()).
## El mensajero se detiene algo al norte del centro de la plaza y el grupo forma
## un anillo a su alrededor, con un hueco al sur por donde llega el jugador.
const MESSENGER_OFFSET: Vector3 = Vector3(0.0, 0.0, -1.5)
const MEETING_RADIUS: float = 2.5
const MEETING_RADIUS_STAGGER: float = 0.2
const MEETING_ARC_SLOTS: int = 6
const MEETING_ARC_START_DEGREES: float = 150.0
## Recorrido del arco: deja 120° libres al sur (hacia el jugador).
const MEETING_ARC_SWEEP_DEGREES: float = 240.0

## Tiempo de partida antes de que el mensajero se ponga en camino (ADR-0013;
## antes, 240 s en ADR-0009 y 120 s en ADR-0012).
@export var arrival_delay: float = 75.0
## Espera máxima, una vez cumplido el reloj, a que el jugador esté en la plaza:
## el mensajero sale como tarde a los 150 s. Mientras tanto, un aviso llama a
## la plaza.
@export var arrival_grace: float = 75.0
@export var arrival_radius: float = 22.0
@export var call_timeout: float = 60.0
## Si está activo, el reloj arranca al conectar el evento con el mundo. La
## escena lo desactiva cuando hay introducción y llama a [method begin] al
## terminarla (ADR-0023).
@export var start_on_bind: bool = true

var phase: int = Phase.IDLE
var completed: bool = false
var pututu_by_player: bool = false

var _player: Node3D = null
var _plaza: Marker3D = null
var _plaza_center: Vector3 = Vector3.ZERO
var _messenger: NpcActor = null
var _curaca: NpcActor = null
var _principals: Array[NpcActor] = []
var _neighbors: Array[NpcActor] = []
var _pututu: Pututu = null

var _begun: bool = false
var _idle_time: float = 0.0
var _phase_time: float = 0.0
var _news_second_timer: float = 0.0
var _news_repeat_allowed: bool = false
var _closing_second_sent: bool = false
var _party_hidden: bool = false
var _arrival_by_grace: bool = false
var _curaca_called: bool = false
var _curaca_is_calling: bool = false
var _wait_cue_sent: bool = false
var _gather_cue_sent: bool = false
var _greeter: NpcActor = null
var _greeted: bool = false
## Paseo de los vecinos antes de la noticia: puntos de cada uno, punto actual y
## pausa restante.
var _wander_routes: Dictionary[NpcActor, PackedVector3Array] = {}
var _wander_index: Dictionary[NpcActor, int] = {}
var _wander_pause: Dictionary[NpcActor, float] = {}


func _ready() -> void:
	set_process(start_on_bind)


func _process(delta: float) -> void:
	step(delta)


## Conecta el evento con los nodos del mundo. Se llama desde la escena que los
## compone; el evento no busca nodos por ruta.
func bind(
	player_node: Node3D,
	plaza_node: Marker3D,
	messenger_node: NpcActor,
	curaca_node: NpcActor,
	principal_nodes: Array[NpcActor],
	neighbor_nodes: Array[NpcActor],
	pututu_node: Pututu
) -> void:
	_player = player_node
	_plaza = plaza_node
	_messenger = messenger_node
	_curaca = curaca_node
	_principals = principal_nodes
	_neighbors = neighbor_nodes
	_pututu = pututu_node
	if _plaza != null:
		_plaza_center = _plaza.global_position
	if _pututu != null:
		_pututu.set_armed(false)
		if not _pututu.played.is_connected(_on_pututu_played):
			_pututu.played.connect(_on_pututu_played)
	if start_on_bind:
		begin()


## Pone en marcha el reloj y pide el subtítulo de apertura. Con
## [member start_on_bind] desactivado, la escena lo llama al terminar la
## introducción (ADR-0023); hasta entonces el evento no avanza.
func begin() -> void:
	if _begun:
		return
	_begun = true
	set_process(true)
	subtitle_requested.emit(KEY_OPENING, OPENING_SECONDS)


## Indica si el reloj del evento ya está en marcha.
func has_begun() -> bool:
	return _begun


## Fija los paseos de los vecinos mientras no ha llegado el mensajero. Cada
## ruta es una lista de puntos que el vecino recorre en bucle, con una pausa en
## cada uno. La escena del mundo conoce el mapa; el evento solo los mueve.
func set_wander_routes(routes: Dictionary[NpcActor, PackedVector3Array]) -> void:
	_wander_routes = routes
	_wander_index.clear()
	_wander_pause.clear()
	var order: int = 0
	for actor: NpcActor in routes:
		_wander_index[actor] = 0
		_wander_pause[actor] = WANDER_PAUSE_STAGGER * float(order)
		order += 1


## Coloca a [param actor] en [param point] para recibir al jugador. No pasea
## hasta que lo saluda; después se une a su ruta.
func set_greeter(actor: NpcActor, point: Vector3) -> void:
	_greeter = actor
	_greeted = false
	if actor != null:
		actor.stop()
		actor.position = point


## Indica si el vecino ya recibió al jugador.
func has_greeted() -> bool:
	return _greeted


## Detiene a un vecino durante [param seconds] (por ejemplo, mientras el
## jugador habla con él). Después retoma su paseo.
func hold(actor: NpcActor, seconds: float) -> void:
	if actor == null:
		return
	actor.stop()
	if _wander_routes.has(actor):
		var current: float = _wander_pause.get(actor, 0.0)
		_wander_pause[actor] = maxf(current, seconds)


## Inicia el evento sin esperar al reloj. Se usa en pruebas y en depuración.
func start() -> void:
	if phase != Phase.IDLE:
		return
	_enter(Phase.ARRIVAL)


## Devuelve `true` si el jugador está dentro del radio de la plaza.
func player_in_plaza() -> bool:
	if _player == null or _plaza == null:
		return false
	return _player.global_position.distance_to(_plaza_center) <= arrival_radius


## Avanza la máquina de estados. Es el único punto de entrada del progreso.
func step(delta: float) -> void:
	match phase:
		Phase.IDLE:
			_step_idle(delta)
		Phase.ARRIVAL:
			_step_arrival(delta)
		Phase.MESSAGE:
			_step_message(delta)
		Phase.CALL:
			_step_call(delta)
		Phase.DEPARTURE:
			_step_departure(delta)
		Phase.DONE:
			_step_done(delta)


func _step_idle(delta: float) -> void:
	_idle_time += delta
	_step_greeter(delta)
	_step_wander(delta)
	if not _wait_cue_sent and WAIT_CUE_TIME < arrival_delay and _idle_time >= WAIT_CUE_TIME:
		_wait_cue_sent = true
		subtitle_requested.emit(KEY_WAIT, WAIT_SECONDS)
	if _idle_time < arrival_delay:
		return
	if player_in_plaza():
		_arrival_by_grace = false
		_enter(Phase.ARRIVAL)
		return
	if not _gather_cue_sent:
		_gather_cue_sent = true
		subtitle_requested.emit(KEY_GATHER, GATHER_SECONDS)
	if _idle_time >= arrival_delay + arrival_grace:
		_arrival_by_grace = true
		_enter(Phase.ARRIVAL)


func _step_greeter(_delta: float) -> void:
	if _greeter == null or _greeted or _player == null:
		return
	_greeter.face(_player.global_position)
	if _greeter.flat_distance_to(_player.global_position) > GREET_DISTANCE:
		return
	_greeted = true
	subtitle_requested.emit(KEY_GREET, GREET_SECONDS)
	if _wander_routes.has(_greeter):
		_wander_pause[_greeter] = GREET_PAUSE


func _step_wander(delta: float) -> void:
	for actor: NpcActor in _wander_routes:
		if actor == _greeter and not _greeted:
			continue
		var route: PackedVector3Array = _wander_routes[actor]
		if route.is_empty():
			continue
		if actor.moving:
			actor.advance(delta)
			continue
		var pause: float = _wander_pause.get(actor, 0.0)
		pause -= delta
		_wander_pause[actor] = pause
		if pause > 0.0:
			continue
		var index: int = _wander_index.get(actor, 0)
		index = (index + 1) % route.size()
		_wander_index[actor] = index
		_wander_pause[actor] = WANDER_PAUSE
		actor.walk_to(route[index])


func _step_arrival(delta: float) -> void:
	_phase_time += delta
	_advance_group(delta)
	if _messenger == null or not _messenger.moving:
		_enter(Phase.MESSAGE)


func _step_message(delta: float) -> void:
	_phase_time += delta
	_advance_group(delta)
	_advance_news_second(delta)
	_maybe_repeat_news()
	if _phase_time >= MESSAGE_DURATION:
		_enter(Phase.CALL)


func _step_call(delta: float) -> void:
	_phase_time += delta
	_advance_group(delta)
	_advance_news_second(delta)
	_maybe_repeat_news()
	if _phase_time >= call_timeout:
		_curaca_calls()


func _step_departure(delta: float) -> void:
	_phase_time += delta
	_advance_group(delta)
	if not _closing_second_sent and _phase_time >= CLOSING_SECOND_DELAY:
		_closing_second_sent = true
		subtitle_requested.emit(KEY_CLOSING_SECOND, CLOSING_SECONDS)
	if _closing_second_sent and _phase_time >= CLOSING_SECOND_DELAY + CLOSING_HOLD:
		_enter(Phase.DONE)
		return
	_hide_party_if_gone()


## Tras el cierre, la comitiva sigue caminando hasta salir por el camino norte.
func _step_done(delta: float) -> void:
	_phase_time += delta
	_advance_group(delta)
	_hide_party_if_gone()


## Oculta la comitiva cuando llega al camino norte o se agota su tiempo.
func _hide_party_if_gone() -> void:
	if _party_hidden:
		return
	if _departure_time() >= DEPARTURE_TIMEOUT or _party_arrived():
		_party_hidden = true
		_hide_party()


## Segundos desde que la comitiva echó a andar.
func _departure_time() -> float:
	if phase == Phase.DEPARTURE:
		return _phase_time
	if phase == Phase.DONE:
		return CLOSING_SECOND_DELAY + CLOSING_HOLD + _phase_time
	return 0.0


func _enter(next_phase: int) -> void:
	phase = next_phase
	_phase_time = 0.0
	phase_changed.emit(phase)
	match phase:
		Phase.ARRIVAL:
			started.emit()
			# Los vecinos dejan su paseo y todo el grupo se acerca al punto
			# donde se detendrá el mensajero, mientras él llega corriendo.
			for actor: NpcActor in _wander_routes:
				actor.stop()
			_gather_group()
			_face_all()
		Phase.MESSAGE:
			if _messenger != null:
				_messenger.stop()
				_messenger.face(_plaza_center + Vector3(0.0, 0.0, 6.0))
			_face_all()
			_send_news()
			# Llega agotado, recobra el aliento y cuenta la noticia con gestos
			# (alcance §5, ADR-0015).
			if _messenger != null:
				_messenger.set_idle_animation(&"talk")
				_messenger.perform(&"tired", MESSENGER_BREATH_SECONDS)
		Phase.CALL:
			if _pututu != null:
				_pututu.set_armed(true)
			subtitle_requested.emit(KEY_CALL, CALL_SECONDS)
			if _messenger != null:
				_messenger.set_idle_animation(&"idle")
			if _curaca != null:
				_curaca.perform(&"talk", CALL_SECONDS)
		Phase.DEPARTURE:
			if _pututu != null:
				_pututu.set_armed(false)
			_closing_second_sent = false
			subtitle_requested.emit(KEY_CLOSING_FIRST, CLOSING_SECONDS)
			_send_party_away()
		Phase.DONE:
			completed = true
			_news_second_timer = 0.0
			finished.emit()


func _send_news() -> void:
	subtitle_requested.emit(KEY_NEWS_FIRST, NEWS_SECONDS)
	_news_second_timer = NEWS_SECOND_DELAY
	_news_repeat_allowed = _arrival_by_grace


func _advance_news_second(delta: float) -> void:
	if _news_second_timer <= 0.0:
		return
	_news_second_timer = maxf(_news_second_timer - delta, 0.0)
	if _news_second_timer <= 0.0:
		subtitle_requested.emit(KEY_NEWS_SECOND, NEWS_SECONDS)


func _maybe_repeat_news() -> void:
	if not _news_repeat_allowed or _phase_time < 1.0:
		return
	if not player_in_plaza():
		return
	_news_repeat_allowed = false
	_send_news()


func _face_all() -> void:
	# El grupo mira al sitio donde se detiene el mensajero, no a su posición
	# durante la carrera: así llega al centro del anillo ya encarado.
	var point: Vector3 = _meeting_point(0)
	if _curaca != null:
		_curaca.face(point)
	for actor: NpcActor in _principals:
		actor.face(point)
	for actor: NpcActor in _neighbors:
		actor.face(point)


## Envía a cada personaje a su hueco del anillo. Se hace al empezar la
## llegada, para que el grupo esté formado cuando el mensajero se detiene.
func _gather_group() -> void:
	if _messenger != null:
		_messenger.walk_to(_meeting_point(0))
	if _curaca != null:
		_curaca.walk_to(_meeting_point(1))
	var index: int = 2
	for actor: NpcActor in _principals:
		actor.walk_to(_meeting_point(index))
		index += 1
	for actor: NpcActor in _neighbors:
		actor.walk_to(_meeting_point(index))
		index += 1


## Punto de reunión de cada personaje. El hueco 0 es el mensajero, en el
## centro; los demás forman un anillo apretado a su alrededor, con el hueco
## hacia el sur por donde llega el jugador. El quero, el pututu y la ofrenda
## quedan fuera del anillo, así que la reunión no los tapa.
func _meeting_point(slot: int) -> Vector3:
	var center: Vector3 = _plaza_center + MESSENGER_OFFSET
	if slot <= 0:
		return center
	var last_slot: int = maxi(MEETING_ARC_SLOTS - 1, 1)
	var t: float = float(slot - 1) / float(last_slot)
	var degrees: float = MEETING_ARC_START_DEGREES + MEETING_ARC_SWEEP_DEGREES * clampf(t, 0.0, 1.0)
	var angle: float = deg_to_rad(degrees)
	var radius: float = MEETING_RADIUS + MEETING_RADIUS_STAGGER * float(slot % 2)
	return center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


func _advance_group(delta: float) -> void:
	for actor: NpcActor in _all_actors():
		actor.advance(delta)


func _exit_point() -> Vector3:
	return _plaza_center + Vector3(0.0, 0.0, -52.0)


func _send_party_away() -> void:
	var exit_point: Vector3 = _exit_point()
	# El mensajero llegó corriendo; de vuelta camina al paso de la comitiva.
	if _messenger != null and _curaca != null:
		_messenger.walk_speed = _curaca.walk_speed
	var index: int = 0
	for actor: NpcActor in _party():
		actor.walk_to(exit_point + Vector3(-1.5 + float(index) * 1.5, 0.0, 0.0))
		index += 1
	for actor: NpcActor in _neighbors:
		actor.stop()
		actor.face(exit_point)


func _party_arrived() -> bool:
	var exit_point: Vector3 = _exit_point()
	for actor: NpcActor in _party():
		if actor.flat_distance_to(exit_point) > 3.0:
			return false
	return true


func _hide_party() -> void:
	for actor: NpcActor in _party():
		actor.hide_actor()


## La comitiva son el mensajero, que la guía de vuelta al Cusco (ADR-0026), el
## curaca y los hombres principales. Los vecinos se quedan en la plaza: el
## cierre narra solo la partida del grupo.
func _party() -> Array[NpcActor]:
	var party: Array[NpcActor] = []
	if _messenger != null:
		party.append(_messenger)
	if _curaca != null:
		party.append(_curaca)
	for actor: NpcActor in _principals:
		party.append(actor)
	return party


func _all_actors() -> Array[NpcActor]:
	# `_party()` ya incluye al mensajero: no se añade dos veces, o avanzaría
	# al doble de velocidad al caminar.
	var actors: Array[NpcActor] = _party()
	for actor: NpcActor in _neighbors:
		actors.append(actor)
	return actors


func _curaca_calls() -> void:
	if _curaca_called:
		return
	_curaca_called = true
	if _pututu == null:
		_enter(Phase.DEPARTURE)
		return
	pututu_by_player = false
	_curaca_is_calling = true
	_pututu.force_play()
	_curaca_is_calling = false


func _on_pututu_played() -> void:
	if phase != Phase.CALL:
		return
	pututu_by_player = not _curaca_is_calling
	_enter(Phase.DEPARTURE)
