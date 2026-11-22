class_name PlayerFPS
extends CharacterBody3D
## Controlador en primera persona.
##
## Movimiento relativo a la orientación horizontal, cámara con límite de pitch,
## reacción a la pausa, interacción por rayo y head bobbing calculado en el tick
## de física.
##
## La cámara tiene dos estados además de la exploración: el bloqueo de controles
## (diario) y el encuadre de diálogo. En el diálogo el jugador no anda ni mira
## con el ratón; la cámara gira hacia la cara del interlocutor y, al cerrar,
## vuelve a la orientación que tenía. La transición es suave para no cortar la
## inmersión ni provocar mareo.

signal interactable_focused(interactable: Interactable)
signal interactable_unfocused()
signal interacted(interactable: Interactable)
signal footstep_taken()

## Fases del encuadre de diálogo.
enum FocusPhase {
	NONE,
	FOCUS,
	HOLD,
	RESTORE,
}

const MAX_INTERACTABLE_SEARCH_DEPTH: int = 8
const BOB_PHASE_WRAP: float = TAU * 2.0
## Punto del ciclo de balanceo en que suena el paso: el mínimo de sin(), cuando
## la cámara está más baja.
const FOOTSTEP_CYCLE_POINT: float = 0.75
## Metadato con el que un cuerpo del mundo declara su superficie de paso.
const FOOTSTEP_SURFACE_META: StringName = &"footstep_surface"
## Distancia bajo los pies a la que se busca el suelo para elegir el sonido.
const FOOTSTEP_PROBE_DEPTH: float = 0.4
## Segundos tras _ready() antes del intento de captura de respaldo.
const INITIAL_CAPTURE_DELAY: float = 0.3
## Altura de los ojos del interlocutor a la que mira la cámara al dialogar.
const FOCUS_TARGET_HEIGHT: float = 1.55
## Giro máximo hacia el interlocutor, para no arrancar la mirada de golpe.
const FOCUS_MAX_TURN_DEGREES: float = 72.0
## Suavizado del escalón bajo los pies: cuánto se corrige por segundo.
const STEP_SMOOTH_RATE: float = 7.0
## Hundimiento de cámara al aterrizar desde una caída, en metros por m/s.
const LANDING_DIP_PER_SPEED: float = 0.008
const LANDING_DIP_MAX: float = 0.075
## Inclinación lateral de la cámara al desplazarse de lado, en grados.
const STRAFE_SWAY_DEGREES: float = 0.6

@export_group("Movimiento")
@export var walk_speed: float = 3.5
@export var run_speed: float = 6.5
@export var acceleration: float = 10.0
@export var deceleration: float = 12.0
## Proporción de la aceleración que se conserva en el aire.
@export_range(0.0, 1.0, 0.05) var air_control: float = 0.35
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@export_group("Cámara")
@export var mouse_sensitivity: float = 0.15
@export var pitch_limit_degrees: float = 80.0
@export var base_fov: float = 78.0
@export var run_fov_bonus: float = 4.0
@export var dialogue_fov_offset: float = -3.0
@export var focus_seconds: float = 0.35
@export var restore_seconds: float = 0.4

@export_group("Head bobbing")
@export var bob_walk_frequency: float = 1.8
@export var bob_walk_amplitude: float = 0.035
@export var bob_run_frequency: float = 2.6
@export var bob_run_amplitude: float = 0.06
@export var bob_blend_speed: float = 6.0
@export var bob_min_speed: float = 0.1

@export_group("Pasos")
## Variantes de sonido de paso por defecto (suelo sin superficie declarada);
## se alternan en orden. Vacío: sin pasos por defecto.
@export var footstep_streams: Array[AudioStream] = []
## Conjuntos por superficie; tienen prioridad sobre los de por defecto.
@export var footstep_sets: Array[FootstepSet] = []
@export var footstep_volume_db: float = -10.0

@export_group("Estamina")
@export var stamina: StaminaComponent
@export var run_stamina_cost_per_second: float = 15.0
@export var run_resume_stamina: float = 25.0

@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var interaction_ray: RayCast3D = $Head/Camera3D/InteractionRay

var _pitch: float = 0.0
var _bob_phase: float = 0.0
var _bob_weight: float = 0.0
var _camera_base_position: Vector3 = Vector3.ZERO
var _focused_interactable: Interactable = null
var _focused_candidate: Interactable = null
var _focused_collider: Object = null
var _run_blocked: bool = false
var _step_cycle: float = 0.0
var _footstep_index: int = 0
var _controls_locked: bool = false
var jump: PlayerJump = PlayerJump.new()
var _focus_phase: FocusPhase = FocusPhase.NONE
var _focus_target: Node3D = null
var _focus_elapsed: float = 0.0
var _focus_from_yaw: float = 0.0
var _focus_from_pitch: float = 0.0
var _focus_to_yaw: float = 0.0
var _focus_to_pitch: float = 0.0
var _restore_from_yaw: float = 0.0
var _restore_from_pitch: float = 0.0
var _restore_to_yaw: float = 0.0
var _restore_to_pitch: float = 0.0
var _pre_dialogue_yaw: float = 0.0
var _pre_dialogue_pitch: float = 0.0
var _step_offset: float = 0.0
var _last_ground_y: float = 0.0
var _landing_dip: float = 0.0
var _sway: float = 0.0
var _fov_target: float = 78.0


func _ready() -> void:
	_camera_base_position = camera.position
	base_fov = camera.fov if not is_zero_approx(camera.fov) else base_fov
	_fov_target = base_fov
	_last_ground_y = global_position.y
	# El cuerpo se apoya en el suelo y no se queda flotando al subir un escalón.
	floor_snap_length = 0.32
	floor_stop_on_slope = true
	floor_max_angle = deg_to_rad(46.0)
	camera.near = 0.06
	# No se captura aquí: durante _ready() la ventana puede no ser visible aún y
	# X11 rechaza la captura («NO GRAB») aunque declare tener el foco. Se captura
	# al recibir el foco, con un clic o, como respaldo, poco después de arrancar.
	if is_inside_tree():
		get_tree().create_timer(INITIAL_CAPTURE_DELAY).timeout.connect(_capture_mouse_if_allowed)
	if stamina == null:
		stamina = StaminaComponent.find_in(self)
	var manager: GameManagerService = GameManagerService.instance()
	if manager != null:
		manager.pause_changed.connect(_on_game_manager_pause_changed)


func _notification(what: int) -> void:
	# El sistema solo concede la captura a una ventana con foco. Se captura al
	# recibirlo (también al arrancar) y se recaptura al recuperarlo.
	if what == NOTIFICATION_WM_WINDOW_FOCUS_IN or what == NOTIFICATION_APPLICATION_FOCUS_IN:
		_capture_mouse_if_allowed()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		var button: InputEventMouseButton = event as InputEventMouseButton
		if button.pressed and Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not _is_game_paused():
			_capture_mouse_if_allowed()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("interact"):
		if _controls_locked:
			return
		try_interact()
		get_viewport().set_input_as_handled()
		return
	if not (event is InputEventMouseMotion):
		return
	if _controls_locked or Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	rotate_y(-motion.relative.x * deg_to_rad(mouse_sensitivity))
	_pitch = clamp_pitch(_pitch - motion.relative.y * deg_to_rad(mouse_sensitivity), pitch_limit_degrees)
	head.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	jump.request(Input.is_action_just_pressed("jump"), is_on_floor(), _controls_locked)
	jump.apply(self, is_on_floor(), _controls_locked)
	_move(delta)
	_update_focus(delta)
	_apply_camera(delta)
	update_interaction()


## Actualiza el interactuable enfocado. El candidato se recalcula al cambiar el
## collider; el foco se actualiza además cuando cambia su disponibilidad.
func update_interaction() -> void:
	var collider: Object = null
	if interaction_ray.is_colliding():
		collider = interaction_ray.get_collider()
	if collider != _focused_collider:
		_focused_collider = collider
		_focused_candidate = null
		if collider is Node:
			_focused_candidate = find_interactable_from(collider as Node)
	var available: Interactable = _focused_candidate
	if available != null and not available.is_available():
		available = null
	if available == _focused_interactable:
		return
	_focused_interactable = available
	if available != null:
		interactable_focused.emit(available)
	else:
		interactable_unfocused.emit()


## Busca el interactuable más cercano subiendo por los ancestros del nodo.
func find_interactable_from(start: Node) -> Interactable:
	var node: Node = start
	var depth: int = 0
	var scene_root: Node = null
	if get_tree() != null:
		scene_root = get_tree().current_scene
	while node != null and depth <= MAX_INTERACTABLE_SEARCH_DEPTH:
		if node is Interactable:
			return node as Interactable
		if node == scene_root:
			break
		node = node.get_parent()
		depth += 1
	return null


## Ejecuta la interacción sobre el objeto enfocado, si existe y está disponible.
func try_interact() -> void:
	if _controls_locked:
		return
	if _focused_interactable == null:
		return
	if not _focused_interactable.is_available():
		return
	_focused_interactable.interact(self)
	interacted.emit(_focused_interactable)


## Bloquea o libera el movimiento y la mirada. El diario lo usa para detener al
## jugador sin apagar su física ni el mundo.
func set_controls_locked(locked: bool) -> void:
	_controls_locked = locked
	if locked:
		velocity.x = 0.0
		velocity.z = 0.0
		_fov_target = base_fov
		_clear_focus()


## Indica si el jugador tiene los controles bloqueados.
func is_controls_locked() -> bool:
	return _controls_locked


## Muestra u oculta el puntero para una UI modal (diario) sin cambiar la pausa.
## Al ocultarlo se recaptura solo si la ventana tiene foco y el juego no está
## pausado, con la misma regla que el resto del jugador.
func set_pointer_visible(pointer_visible: bool) -> void:
	if pointer_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		_capture_mouse_if_allowed()


## Empieza un diálogo: bloquea los controles y gira la cámara hacia la cara de
## [param target]. Con `null` solo bloquea, para diálogos sin interlocutor.
func begin_dialogue(target: Node3D = null) -> void:
	_controls_locked = true
	velocity.x = 0.0
	velocity.z = 0.0
	_pre_dialogue_yaw = rotation.y
	_pre_dialogue_pitch = _pitch
	_focus_target = target
	_focus_from_yaw = rotation.y
	_focus_from_pitch = _pitch
	_focus_to_yaw = _pre_dialogue_yaw
	_focus_to_pitch = _pre_dialogue_pitch
	if target != null and target.is_inside_tree():
		_focus_to_yaw = _focus_yaw_towards(target)
		_focus_to_pitch = _focus_pitch_towards(target)
	_focus_phase = FocusPhase.FOCUS
	_focus_elapsed = 0.0
	_fov_target = base_fov + dialogue_fov_offset


## Termina el diálogo y devuelve la cámara a la orientación previa. Los
## controles se liberan cuando la transición acaba.
func end_dialogue() -> void:
	if _focus_phase == FocusPhase.NONE:
		_controls_locked = false
		_fov_target = base_fov
		return
	_restore_from_yaw = rotation.y
	_restore_from_pitch = _pitch
	_restore_to_yaw = _pre_dialogue_yaw
	_restore_to_pitch = _pre_dialogue_pitch
	_focus_target = null
	_focus_phase = FocusPhase.RESTORE
	_focus_elapsed = 0.0
	_fov_target = base_fov


## Indica si la cámara está encuadrando a un interlocutor.
func is_dialogue_focused() -> bool:
	return _focus_phase == FocusPhase.FOCUS or _focus_phase == FocusPhase.HOLD


## Orientación horizontal hacia la cabeza de [param target], limitada para que
## la cámara no gire 180° de golpe.
func _focus_yaw_towards(target: Node3D) -> float:
	var to_target: Vector3 = _focus_point_for(target) - global_position
	to_target.y = 0.0
	if to_target.length_squared() < 0.001:
		return rotation.y
	var desired: float = atan2(-to_target.x, -to_target.z)
	var limit: float = deg_to_rad(FOCUS_MAX_TURN_DEGREES)
	return rotation.y + clampf(wrapf(desired - rotation.y, -PI, PI), -limit, limit)


## Inclinación hacia la cabeza de [param target], dentro del límite de pitch.
func _focus_pitch_towards(target: Node3D) -> float:
	# La altura de los ojos está en Head, no en la cámara: su posición local es
	# cero. Usar la cámara dejaba el encuadre mirando 38° hacia arriba.
	var eye: Vector3 = head.global_position
	var to_target: Vector3 = _focus_point_for(target) - eye
	var horizontal: float = Vector2(to_target.x, to_target.z).length()
	if horizontal < 0.001:
		return _pitch
	return clamp_pitch(atan2(to_target.y, horizontal), pitch_limit_degrees)


## Punto de la cara del interlocutor. Los personajes con esqueleto exponen
## [method focus_point]; así la tejedora arrodillada no se encuadra como si
## estuviera de pie.
func _focus_point_for(target: Node3D) -> Vector3:
	if target.has_method("focus_point"):
		var point: Variant = target.call("focus_point")
		if point is Vector3:
			return point
	return target.global_position + Vector3.UP * FOCUS_TARGET_HEIGHT


func _clear_focus() -> void:
	_focus_phase = FocusPhase.NONE
	_focus_target = null
	_focus_elapsed = 0.0


## Avanza la transición del encuadre. En HOLD sigue lentamente la cara del
## interlocutor; en RESTORE vuelve a la orientación de antes del diálogo.
func _update_focus(delta: float) -> void:
	if _focus_phase == FocusPhase.NONE:
		return
	var smooth: float = 0.0
	if _focus_phase == FocusPhase.HOLD:
		if _focus_target != null and _focus_target.is_inside_tree():
			_focus_to_yaw = _focus_yaw_towards(_focus_target)
			_focus_to_pitch = _focus_pitch_towards(_focus_target)
		var follow: float = 1.0 - exp(-2.5 * delta)
		rotation.y = lerp_angle(rotation.y, _focus_to_yaw, follow)
		_pitch = lerpf(_pitch, _focus_to_pitch, follow)
		head.rotation.x = _pitch
		return
	_focus_elapsed += delta
	var duration: float = focus_seconds if _focus_phase == FocusPhase.FOCUS else restore_seconds
	var t: float = clampf(_focus_elapsed / maxf(duration, 0.001), 0.0, 1.0)
	smooth = t * t * (3.0 - 2.0 * t)
	if _focus_phase == FocusPhase.FOCUS:
		rotation.y = lerp_angle(_focus_from_yaw, _focus_to_yaw, smooth)
		_pitch = lerpf(_focus_from_pitch, _focus_to_pitch, smooth)
	else:
		rotation.y = lerp_angle(_restore_from_yaw, _restore_to_yaw, smooth)
		_pitch = lerpf(_restore_from_pitch, _restore_to_pitch, smooth)
	head.rotation.x = _pitch
	if t < 1.0:
		return
	if _focus_phase == FocusPhase.FOCUS:
		_focus_phase = FocusPhase.HOLD
	else:
		_focus_phase = FocusPhase.NONE
		_controls_locked = false


## Decide si el jugador corre y aplica el consumo de estamina.
##
## Sin componente de estamina, correr no tiene límite. Al agotarse, el jugador
## no vuelve a correr hasta alcanzar [member run_resume_stamina].
func update_run_state(has_input: bool, run_pressed: bool, delta: float) -> bool:
	var wants_run: bool = has_input and run_pressed
	if stamina == null:
		return wants_run
	if _run_blocked:
		if stamina.get_current() >= run_resume_stamina:
			_run_blocked = false
	elif not stamina.has_stamina():
		_run_blocked = true
	if not wants_run or _run_blocked:
		return false
	stamina.consume(run_stamina_cost_per_second * delta)
	return true


## Limita un ángulo de pitch al rango simétrico definido por [param limit_degrees].
static func clamp_pitch(pitch: float, limit_degrees: float) -> float:
	var limit: float = deg_to_rad(limit_degrees)
	return clampf(pitch, -limit, limit)


## Devuelve el modo de ratón que corresponde al estado de pausa.
static func mouse_mode_for_pause(paused: bool) -> Input.MouseMode:
	return Input.MOUSE_MODE_VISIBLE if paused else Input.MOUSE_MODE_CAPTURED


## Indica si debe pedirse la captura del ratón: solo en juego y con la ventana
## enfocada.
static func should_capture_mouse(paused: bool, window_focused: bool) -> bool:
	return window_focused and not paused


## Calcula el desplazamiento local de la cámara para un tick de física.
##
## [param horizontal_speed] es la velocidad horizontal en m/s y [param grounded]
## indica si el jugador está apoyado. La posición se recalcula desde cero en cada
## llamada, por lo que no acumula desplazamiento.
func calculate_head_bob_offset(horizontal_speed: float, grounded: bool, delta: float) -> Vector3:
	var moving: bool = grounded and horizontal_speed > bob_min_speed and not _controls_locked
	var target_weight: float = 1.0 if moving else 0.0
	_bob_weight = move_toward(_bob_weight, target_weight, bob_blend_speed * delta)
	var speed_ratio: float = clampf(horizontal_speed / run_speed, 0.0, 1.0)
	var frequency: float = bob_frequency_for(horizontal_speed)
	var amplitude: float = lerpf(bob_walk_amplitude, bob_run_amplitude, speed_ratio)
	if moving:
		_bob_phase = fposmod(_bob_phase + delta * frequency * TAU, BOB_PHASE_WRAP)
	var offset: Vector3 = Vector3.ZERO
	offset.y = sin(_bob_phase) * amplitude * _bob_weight
	offset.x = cos(_bob_phase * 0.5) * amplitude * 0.5 * _bob_weight
	return offset


## Frecuencia del balanceo (y de los pasos) para una velocidad horizontal.
func bob_frequency_for(horizontal_speed: float) -> float:
	var speed_ratio: float = clampf(horizontal_speed / run_speed, 0.0, 1.0)
	return lerpf(bob_walk_frequency, bob_run_frequency, speed_ratio)


## Avanza el ciclo de pasos al mismo ritmo que el balanceo. Devuelve `true` en
## el tick en que el ciclo cruza [constant FOOTSTEP_CYCLE_POINT], es decir, un
## paso por ciclo de balanceo vertical.
func advance_footstep(horizontal_speed: float, grounded: bool, delta: float) -> bool:
	if _controls_locked or not grounded or horizontal_speed <= bob_min_speed:
		return false
	var previous: float = _step_cycle
	var advanced: float = previous + delta * bob_frequency_for(horizontal_speed)
	_step_cycle = fposmod(advanced, 1.0)
	var crossed: bool = previous < FOOTSTEP_CYCLE_POINT and advanced >= FOOTSTEP_CYCLE_POINT
	var wrapped_past: bool = advanced >= 1.0 + FOOTSTEP_CYCLE_POINT
	return crossed or wrapped_past


func _move(delta: float) -> void:
	var input_vector: Vector2 = Vector2.ZERO
	var run_pressed: bool = false
	if not _controls_locked:
		input_vector = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
		run_pressed = Input.is_action_pressed("run")
	var direction: Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	var has_input: bool = input_vector.length_squared() > 0.0
	var is_running: bool = update_run_state(has_input, run_pressed, delta)
	var target_speed: float = run_speed if is_running else walk_speed
	var target_velocity: Vector3 = direction * target_speed
	var rate: float = acceleration if has_input else deceleration
	if not is_on_floor():
		rate *= air_control
	# Suavizado exponencial: el arranque y la frenada tienen peso, no un corte
	# lineal. A 60 Hz el factor es equivalente al antiguo move_toward, pero se
	# comporta igual a cualquier tasa de refresco.
	var blend: float = 1.0 - exp(-rate * delta)
	velocity.x = lerpf(velocity.x, target_velocity.x, blend)
	velocity.z = lerpf(velocity.z, target_velocity.z, blend)
	if absf(velocity.x) < 0.015:
		velocity.x = 0.0
	if absf(velocity.z) < 0.015:
		velocity.z = 0.0
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		# Un aterrizaje desde una caída corta hunde un poco la cámara y luego
		# se recupera: el cuerpo pesa sin sacudir la vista.
		if velocity.y < -2.0:
			_landing_dip = minf(-velocity.y * LANDING_DIP_PER_SPEED, LANDING_DIP_MAX)
		if velocity.y < 0.0:
			velocity.y = 0.0
		return
	velocity.y -= gravity * delta


func _apply_camera(delta: float) -> void:
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var bob: Vector3 = calculate_head_bob_offset(horizontal_speed, is_on_floor(), delta)
	_update_step_smoothing(delta)
	_landing_dip = move_toward(_landing_dip, 0.0, 0.22 * delta)
	var strafe: float = Input.get_axis("move_left", "move_right") if not _controls_locked else 0.0
	var sway_target: float = -strafe * deg_to_rad(STRAFE_SWAY_DEGREES) * _bob_weight
	_sway = lerpf(_sway, sway_target, 1.0 - exp(-8.0 * delta))
	camera.rotation.z = _sway
	camera.position = _camera_base_position + bob + Vector3(0.0, _step_offset - _landing_dip, 0.0)
	_update_fov(horizontal_speed, delta)
	if advance_footstep(horizontal_speed, is_on_floor(), delta):
		_play_footstep()


## Corrige el salto vertical de la cámara al subir un escalón o una rampa
## corta: el cuerpo sube, pero la vista lo acompaña con un pequeño retardo.
func _update_step_smoothing(delta: float) -> void:
	if is_on_floor():
		var vertical_delta: float = global_position.y - _last_ground_y
		if absf(vertical_delta) < 0.4:
			_step_offset = clampf(_step_offset - vertical_delta, -0.14, 0.14)
	_last_ground_y = global_position.y
	_step_offset = move_toward(_step_offset, 0.0, STEP_SMOOTH_RATE * delta)


## Ajusta el campo de visión: se abre al correr y se cierra al dialogar.
func _update_fov(horizontal_speed: float, delta: float) -> void:
	var speed_ratio: float = clampf(horizontal_speed / maxf(run_speed, 0.01), 0.0, 1.0)
	var run_weight: float = smoothstep(0.62, 1.0, speed_ratio)
	_fov_target = base_fov + run_fov_bonus * run_weight
	if _controls_locked:
		_fov_target += dialogue_fov_offset
	camera.fov = lerpf(camera.fov, _fov_target, 1.0 - exp(-4.5 * delta))


## Superficie declarada por un cuerpo del mundo, o vacía si no declara ninguna.
static func surface_of(collider: Object) -> StringName:
	if collider == null or not collider.has_meta(FOOTSTEP_SURFACE_META):
		return &""
	var surface: StringName = collider.get_meta(FOOTSTEP_SURFACE_META)
	return surface


## Devuelve el siguiente sonido de paso para [param surface] y avanza la
## alternancia. Sin conjunto para esa superficie usa [member footstep_streams];
## devuelve [code]null[/code] si no hay ninguno.
func next_footstep_stream(surface: StringName) -> AudioStream:
	var streams: Array[AudioStream] = footstep_streams
	if surface != &"":
		for footstep_set: FootstepSet in footstep_sets:
			if footstep_set != null and footstep_set.surface == surface and not footstep_set.streams.is_empty():
				streams = footstep_set.streams
				break
	if streams.is_empty():
		return null
	var stream: AudioStream = streams[_footstep_index % streams.size()]
	_footstep_index += 1
	return stream


func _floor_surface() -> StringName:
	var space: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var origin: Vector3 = global_position + Vector3.UP * 0.1
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(
		origin, origin + Vector3.DOWN * (0.1 + FOOTSTEP_PROBE_DEPTH), collision_mask, [get_rid()]
	)
	var hit: Dictionary = space.intersect_ray(query)
	if hit.is_empty():
		return &""
	var collider: Object = hit.get("collider")
	return surface_of(collider)


func _play_footstep() -> void:
	footstep_taken.emit()
	var audio: AudioManagerService = AudioManagerService.instance()
	if audio == null:
		return
	var stream: AudioStream = next_footstep_stream(_floor_surface())
	if stream == null:
		return
	audio.play_sfx(stream, footstep_volume_db)


func _on_game_manager_pause_changed(paused: bool) -> void:
	if paused:
		Input.mouse_mode = mouse_mode_for_pause(paused)
		return
	_capture_mouse_if_allowed()


func _capture_mouse_if_allowed() -> void:
	if not is_inside_tree():
		return
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		return
	if not should_capture_mouse(_is_game_paused(), DisplayServer.window_is_focused()):
		return
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _is_game_paused() -> bool:
	var manager: GameManagerService = GameManagerService.instance()
	if manager == null:
		return false
	return manager.is_paused()
