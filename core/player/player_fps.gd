class_name PlayerFPS
extends CharacterBody3D
## Controlador en primera persona.
##
## Movimiento relativo a la orientación horizontal, cámara con límite de pitch,
## reacción a la pausa, interacción por rayo y head bobbing calculado en el tick
## de física.

signal interactable_focused(interactable: Interactable)
signal interactable_unfocused()

const MAX_INTERACTABLE_SEARCH_DEPTH: int = 8
const BOB_PHASE_WRAP: float = TAU * 2.0

@export_group("Movimiento")
@export var walk_speed: float = 3.5
@export var run_speed: float = 6.5
@export var acceleration: float = 10.0
@export var deceleration: float = 12.0
@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity", 9.8)

@export_group("Cámara")
@export var mouse_sensitivity: float = 0.15
@export var pitch_limit_degrees: float = 80.0

@export_group("Head bobbing")
@export var bob_walk_frequency: float = 1.8
@export var bob_walk_amplitude: float = 0.035
@export var bob_run_frequency: float = 2.6
@export var bob_run_amplitude: float = 0.06
@export var bob_blend_speed: float = 6.0
@export var bob_min_speed: float = 0.1

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


func _ready() -> void:
	_camera_base_position = camera.position
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if stamina == null:
		stamina = StaminaComponent.find_in(self)
	if GameManager != null:
		GameManager.pause_changed.connect(_on_game_manager_pause_changed)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		try_interact()
		get_viewport().set_input_as_handled()
		return
	if not (event is InputEventMouseMotion):
		return
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
		return
	var motion: InputEventMouseMotion = event as InputEventMouseMotion
	rotate_y(-motion.relative.x * deg_to_rad(mouse_sensitivity))
	_pitch = clamp_pitch(_pitch - motion.relative.y * deg_to_rad(mouse_sensitivity), pitch_limit_degrees)
	head.rotation.x = _pitch


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_move(delta)
	_apply_head_bob(delta)
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
	if _focused_interactable == null:
		return
	if not _focused_interactable.is_available():
		return
	_focused_interactable.interact(self)


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


## Calcula el desplazamiento local de la cámara para un tick de física.
##
## [param horizontal_speed] es la velocidad horizontal en m/s y [param grounded]
## indica si el jugador está apoyado. La posición se recalcula desde cero en cada
## llamada, por lo que no acumula desplazamiento.
func calculate_head_bob_offset(horizontal_speed: float, grounded: bool, delta: float) -> Vector3:
	var moving: bool = grounded and horizontal_speed > bob_min_speed
	var target_weight: float = 1.0 if moving else 0.0
	_bob_weight = move_toward(_bob_weight, target_weight, bob_blend_speed * delta)
	var speed_ratio: float = clampf(horizontal_speed / run_speed, 0.0, 1.0)
	var frequency: float = lerpf(bob_walk_frequency, bob_run_frequency, speed_ratio)
	var amplitude: float = lerpf(bob_walk_amplitude, bob_run_amplitude, speed_ratio)
	if moving:
		_bob_phase = fposmod(_bob_phase + delta * frequency * TAU, BOB_PHASE_WRAP)
	var offset: Vector3 = Vector3.ZERO
	offset.y = sin(_bob_phase) * amplitude * _bob_weight
	offset.x = cos(_bob_phase * 0.5) * amplitude * 0.5 * _bob_weight
	return offset


func _move(delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction: Vector3 = (transform.basis * Vector3(input_vector.x, 0.0, input_vector.y)).normalized()
	var has_input: bool = input_vector.length_squared() > 0.0
	var run_pressed: bool = Input.is_action_pressed("run")
	var is_running: bool = update_run_state(has_input, run_pressed, delta)
	var target_speed: float = run_speed if is_running else walk_speed
	var target_velocity: Vector3 = direction * target_speed
	var rate: float = acceleration if has_input else deceleration
	velocity.x = move_toward(velocity.x, target_velocity.x, rate * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, rate * delta)
	move_and_slide()


func _apply_gravity(delta: float) -> void:
	if is_on_floor():
		if velocity.y < 0.0:
			velocity.y = 0.0
		return
	velocity.y -= gravity * delta


func _apply_head_bob(delta: float) -> void:
	var horizontal_speed: float = Vector2(velocity.x, velocity.z).length()
	var offset: Vector3 = calculate_head_bob_offset(horizontal_speed, is_on_floor(), delta)
	camera.position = _camera_base_position + offset


func _on_game_manager_pause_changed(paused: bool) -> void:
	Input.mouse_mode = mouse_mode_for_pause(paused)
