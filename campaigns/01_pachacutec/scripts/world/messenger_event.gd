class_name MessengerEvent
extends Node
## Evento de la llegada del mensajero (ADR-0007).
##
## Máquina de estados con disparo garantizado: el evento empieza al entrar en la
## plaza o al agotarse un tiempo máximo, y termina aunque el jugador nunca toque
## el pututu. El avance lo impulsa `step(delta)` para que las pruebas puedan
## recorrer la secuencia sin esperas reales.

enum Phase { IDLE, ARRIVAL, MESSAGE, CALL, DEPARTURE, DONE }

signal started
signal phase_changed(phase: int)
signal finished
signal subtitle_requested(text_key: StringName, seconds: float)

const KEY_OPENING: StringName = &"PCH_NARR_OPENING"
const KEY_NEWS_FIRST: StringName = &"PCH_NARR_NEWS_1"
const KEY_NEWS_SECOND: StringName = &"PCH_NARR_NEWS_2"
const KEY_CLOSING_FIRST: StringName = &"PCH_NARR_CLOSING_1"
const KEY_CLOSING_SECOND: StringName = &"PCH_NARR_CLOSING_2"

const OPENING_SECONDS: float = 5.0
const NEWS_SECONDS: float = 5.0
const NEWS_SECOND_DELAY: float = 5.5
const MESSAGE_DURATION: float = 11.0
const CLOSING_SECONDS: float = 5.0
const CLOSING_SECOND_DELAY: float = 5.5
const DEPARTURE_TIMEOUT: float = 45.0

@export var arrival_radius: float = 22.0
@export var arrival_timeout: float = 120.0
@export var call_timeout: float = 60.0

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

var _idle_time: float = 0.0
var _phase_time: float = 0.0
var _news_second_timer: float = 0.0
var _news_repeat_allowed: bool = false
var _closing_second_sent: bool = false
var _arrival_by_timeout: bool = false
var _curaca_is_calling: bool = false


func _ready() -> void:
	set_process(true)


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
	if _pututu != null and not _pututu.played.is_connected(_on_pututu_played):
		_pututu.played.connect(_on_pututu_played)
	subtitle_requested.emit(KEY_OPENING, OPENING_SECONDS)


## Inicia el evento sin esperar al jugador. Se usa en pruebas y en depuración.
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
			pass


func _step_idle(delta: float) -> void:
	_idle_time += delta
	if player_in_plaza():
		_arrival_by_timeout = false
		_enter(Phase.ARRIVAL)
		return
	if _idle_time >= arrival_timeout:
		_arrival_by_timeout = true
		_enter(Phase.ARRIVAL)


func _step_arrival(delta: float) -> void:
	_phase_time += delta
	if _messenger == null:
		_enter(Phase.MESSAGE)
		return
	if _messenger.advance(delta):
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
	if _phase_time >= DEPARTURE_TIMEOUT or _party_arrived():
		_enter(Phase.DONE)


func _enter(next_phase: int) -> void:
	phase = next_phase
	_phase_time = 0.0
	phase_changed.emit(phase)
	match phase:
		Phase.ARRIVAL:
			started.emit()
			if _messenger != null:
				_messenger.walk_to(_meeting_point(0))
			_face_all()
		Phase.MESSAGE:
			_place_group()
			_send_news()
		Phase.DEPARTURE:
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
	_news_repeat_allowed = _arrival_by_timeout


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
	var point: Vector3 = _plaza_center
	if _messenger != null:
		point = _messenger.global_position
	if _curaca != null:
		_curaca.face(point)
	for actor: NpcActor in _principals:
		actor.face(point)
	for actor: NpcActor in _neighbors:
		actor.face(point)


func _place_group() -> void:
	if _messenger != null:
		_messenger.stop()
		_messenger.face(_plaza_center + Vector3(0.0, 0.0, 6.0))
	if _curaca != null:
		_curaca.walk_to(_meeting_point(1))
	var index: int = 2
	for actor: NpcActor in _principals:
		actor.walk_to(_meeting_point(index))
		index += 1
	for actor: NpcActor in _neighbors:
		actor.walk_to(_meeting_point(index))
		index += 1
	_face_all()


func _meeting_point(slot: int) -> Vector3:
	var angle: float = TAU * float(slot) / 9.0
	var radius: float = 6.0 + 1.1 * float(slot % 3)
	return _plaza_center + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


func _advance_group(delta: float) -> void:
	for actor: NpcActor in _all_actors():
		actor.advance(delta)


func _send_party_away() -> void:
	var exit_point: Vector3 = _plaza_center + Vector3(0.0, 0.0, -66.0)
	var index: int = 0
	for actor: NpcActor in _party():
		actor.walk_to(exit_point + Vector3(-2.0 + float(index) * 1.2, 0.0, 0.0))
		index += 1
	if _messenger != null:
		_messenger.stop()
		_messenger.face(exit_point)


func _party_arrived() -> bool:
	var exit_point: Vector3 = _plaza_center + Vector3(0.0, 0.0, -66.0)
	for actor: NpcActor in _party():
		if actor.flat_distance_to(exit_point) > 3.0:
			return false
	return true


func _party() -> Array[NpcActor]:
	var party: Array[NpcActor] = []
	if _curaca != null:
		party.append(_curaca)
	for actor: NpcActor in _principals:
		party.append(actor)
	for actor: NpcActor in _neighbors:
		party.append(actor)
	return party


func _all_actors() -> Array[NpcActor]:
	var actors: Array[NpcActor] = _party()
	if _messenger != null:
		actors.append(_messenger)
	return actors


func _curaca_calls() -> void:
	if _pututu == null or _curaca == null:
		_enter(Phase.DEPARTURE)
		return
	_curaca_is_calling = true
	_pututu.interact(_curaca)
	_curaca_is_calling = false


func _on_pututu_played() -> void:
	if phase != Phase.CALL:
		return
	pututu_by_player = not _curaca_is_calling
	_enter(Phase.DEPARTURE)
