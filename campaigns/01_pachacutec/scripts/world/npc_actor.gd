class_name NpcActor
extends Node3D
## Personaje no jugable con desplazamiento simple y animaciones del modelo.
##
## Se mueve hacia un punto a velocidad constante y se orienta hacia donde mira.
## El avance lo impulsa quien lo posee (el evento), no `_process`, para que las
## pruebas puedan avanzar la simulación sin esperar en tiempo real.
##
## Con el modelo de esqueleto (ADR-0015) usa su [AnimationPlayer]: camina o
## corre según la velocidad, vuelve a su animación de reposo al detenerse y
## gira la cabeza hacia [member watch_target] cuando está cerca.

## Da un paso (para el sonido de pasos).
signal stepped
## Llega el golpe de una animación de trabajo (el batán del telar, la
## chaquitaclla que entra en la tierra).
signal beat(animation: StringName)

@export var body_color: Color = Color(0.6, 0.45, 0.35, 1.0)
@export var walk_speed: float = 1.8
## Animación de reposo: `idle`, `weave`, `work`, `talk`, `tired`…
@export var idle_animation: StringName = &"idle"
## Si es `false`, al hablar solo gira la cabeza (la tejedora no se aparta del
## telar).
@export var turn_body_to_talk: bool = true

## A partir de esta velocidad corre en lugar de caminar.
const RUN_SPEED_THRESHOLD: float = 2.6
## Velocidad de desplazamiento de cada ciclo a velocidad de reproducción 1
## (dos pasos de 0,75 m en 1,1 s y dos zancadas de 1,3 m en 0,7 s; ADR-0015).
const WALK_CYCLE_SPEED: float = 1.5 / 1.1
const RUN_CYCLE_SPEED: float = 2.6 / 0.7
## Metros por paso, para el sonido de pasos.
const STRIDE_LENGTH: float = 0.75
const RUN_STRIDE_LENGTH: float = 1.3
const BLEND_SECONDS: float = 0.3
const LOOPED_ANIMATIONS: Array[StringName] = [&"idle", &"walk", &"run", &"talk", &"tired", &"weave", &"work"]
## Mirada: distancia máxima, ángulo de giro del cuello y rapidez del cambio.
const LOOK_RADIUS: float = 6.0
const LOOK_YAW_LIMIT_DEGREES: float = 140.0
const LOOK_PITCH_LIMIT_DEGREES: float = 50.0
const LOOK_FADE_PER_SECOND: float = 2.5
## Altura de los ojos del objetivo sobre su origen (el jugador mide 1,7 m).
const LOOK_TARGET_HEIGHT: float = 1.55
const HEAD_BONE: String = "head"
## Instante del golpe dentro de cada ciclo de trabajo, en segundos (las
## funciones de `_anim_weave` y `_anim_work` del generador, ADR-0015).
const ANIMATION_BEATS: Dictionary[StringName, float] = {&"weave": 0.7, &"work": 1.15}
## Sonido de pasos: volumen y distancia a la que deja de oírse.
const STEP_VOLUME_DB: float = -6.0
const STEP_MAX_DISTANCE: float = 22.0

@onready var body: MeshInstance3D = $Body
@onready var collision: StaticBody3D = $Collision

var target: Vector3 = Vector3.ZERO
var moving: bool = false
## Nodo al que mira cuando está cerca (normalmente el jugador).
var watch_target: Node3D = null
var _idle_tween: Tween = null
var _animation_player: AnimationPlayer = null
var _look: LookAtModifier3D = null
var _look_point: Marker3D = null
var _perform_animation: StringName = &""
var _perform_left: float = 0.0
var _stride_distance: float = 0.0
var _last_position: float = -1.0
var _steps_player: AudioStreamPlayer3D = null
var _step_streams: Array[AudioStream] = []
var _step_index: int = 0


func _ready() -> void:
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = body_color
	material.roughness = 1.0
	body.material_override = material
	_idle_tween = create_tween().set_loops()
	_idle_tween.tween_property(body, "position:y", 0.03, 0.9).as_relative()
	_idle_tween.tween_property(body, "position:y", -0.03, 0.9).as_relative()


## Asigna el modelo cargado. Si trae [AnimationPlayer] y esqueleto, el
## personaje pasa a animarse con ellos y el balanceo del bloqueo se detiene.
func set_model(model: Node3D) -> void:
	if model == null:
		return
	_animation_player = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if _animation_player == null:
		return
	_prepare_loops(_animation_player)
	if _idle_tween != null and _idle_tween.is_valid():
		_idle_tween.kill()
	body.position.y = 0.85
	var skeletons: Array[Node] = model.find_children("*", "Skeleton3D", true, false)
	if not skeletons.is_empty():
		_setup_look(skeletons[0] as Skeleton3D)
	_play(idle_animation)
	# Cada personaje empieza su reposo en un punto distinto del ciclo, para que
	# no respiren todos a la vez.
	var length: float = _animation_player.current_animation_length
	if length > 0.0:
		_animation_player.seek(fmod(float(absi(hash(String(name)))) * 0.618, 1.0) * length, true)


## Indica si el personaje tiene modelo con animaciones.
func is_animated() -> bool:
	return _animation_player != null


## Animación que suena ahora (vacía si no hay modelo animado).
func current_animation() -> StringName:
	if _animation_player == null:
		return &""
	return StringName(_animation_player.current_animation)


## Velocidad de reproducción de la animación actual.
func animation_speed() -> float:
	return _animation_player.get_playing_speed() if _animation_player != null else 0.0


## [AnimationPlayer] del modelo, o `null` (para las pruebas).
func animation_player() -> AnimationPlayer:
	return _animation_player


## Modificador que gira la cabeza, o `null` si no hay esqueleto.
func look_modifier() -> LookAtModifier3D:
	return _look


## Cambia la animación de reposo; si está quieto, la pone ya.
func set_idle_animation(animation: StringName) -> void:
	idle_animation = animation
	if not moving and _perform_left <= 0.0:
		_play(idle_animation)


## Hace [param animation] durante [param seconds] y vuelve al reposo. Si echa
## a andar antes, la interrumpe.
func perform(animation: StringName, seconds: float) -> void:
	_perform_animation = animation
	_perform_left = seconds
	if not moving:
		_play(animation)


## Fija un destino. La orientación se actualiza al empezar a caminar.
func walk_to(point: Vector3) -> void:
	target = Vector3(point.x, global_position.y, point.z)
	moving = true
	_perform_left = 0.0
	face(target)
	_play_locomotion()


## Se detiene donde está.
func stop() -> void:
	moving = false
	_stride_distance = 0.0
	_play(_perform_animation if _perform_left > 0.0 else idle_animation)


## Gira el cuerpo hacia un punto, sin inclinarlo.
func face(point: Vector3) -> void:
	var flat: Vector3 = Vector3(point.x, global_position.y, point.z)
	if flat.is_equal_approx(global_position):
		return
	look_at(flat, Vector3.UP)


## Avanza hacia el destino. Devuelve `true` si acaba de llegar.
func advance(delta: float) -> bool:
	if not moving:
		return false
	var distance: float = global_position.distance_to(target)
	var step: float = walk_speed * delta
	if distance <= step:
		global_position = target
		stop()
		return true
	global_position = global_position.move_toward(target, step)
	_stride_distance += step
	var stride: float = RUN_STRIDE_LENGTH if walk_speed >= RUN_SPEED_THRESHOLD else STRIDE_LENGTH
	if _stride_distance >= stride:
		_stride_distance -= stride
		stepped.emit()
	return false


func _process(delta: float) -> void:
	if _perform_left > 0.0:
		_perform_left -= delta
		if _perform_left <= 0.0 and not moving:
			_play(idle_animation)
	_update_look(delta)
	_check_beat()


## Da voz a los pasos con [param streams], que se alternan en orden. El sonido
## sale del personaje (3D) por el bus de efectos.
func set_footsteps(streams: Array[AudioStream]) -> void:
	_step_streams = streams.duplicate()
	if _step_streams.is_empty():
		return
	if _steps_player == null:
		_steps_player = AudioStreamPlayer3D.new()
		_steps_player.name = "Steps"
		_steps_player.bus = &"SFX"
		_steps_player.volume_db = STEP_VOLUME_DB
		_steps_player.max_distance = STEP_MAX_DISTANCE
		_steps_player.unit_size = 4.0
		add_child(_steps_player)
		stepped.connect(_play_step)


func _play_step() -> void:
	if _steps_player == null or not _steps_player.is_inside_tree():
		return
	_steps_player.stream = _step_streams[_step_index % _step_streams.size()]
	_step_index += 1
	# La carrera pisa más fuerte.
	_steps_player.volume_db = STEP_VOLUME_DB + (4.0 if walk_speed >= RUN_SPEED_THRESHOLD else 0.0)
	_steps_player.pitch_scale = 0.94 + 0.04 * float(_step_index % 3)
	_steps_player.play()


## Emite [signal beat] cuando la animación de trabajo pasa por su golpe.
func _check_beat() -> void:
	if _animation_player == null or not _animation_player.is_playing():
		_last_position = -1.0
		return
	var animation: StringName = StringName(_animation_player.current_animation)
	if not ANIMATION_BEATS.has(animation):
		_last_position = -1.0
		return
	var playback: float = _animation_player.current_animation_position
	var at: float = ANIMATION_BEATS[animation]
	if _last_position >= 0.0:
		var crossed: bool = _last_position < at and playback >= at
		# La animación dio la vuelta y el golpe quedó dentro del salto.
		var wrapped: bool = playback < _last_position and (_last_position < at or playback >= at)
		if crossed or wrapped:
			beat.emit(animation)
	_last_position = playback


## Distancia horizontal al punto indicado.
func flat_distance_to(point: Vector3) -> float:
	return Vector2(global_position.x, global_position.z).distance_to(Vector2(point.x, point.z))


## Indica si quiere mirar a [member watch_target] ahora mismo: quieto, cerca y
## por delante (no gira la cabeza hacia la espalda).
func wants_to_look() -> bool:
	if watch_target == null or moving or not is_inside_tree() or not watch_target.is_inside_tree():
		return false
	var to_target: Vector3 = watch_target.global_position - global_position
	to_target.y = 0.0
	if to_target.length() > LOOK_RADIUS or to_target.length() < 0.3:
		return false
	var forward: Vector3 = -global_transform.basis.z
	forward.y = 0.0
	return forward.normalized().dot(to_target.normalized()) > -0.2


## Saca al personaje de la escena visible y de la colisión. Se usa cuando la
## comitiva se marcha: no debe quedar plantada contra el muro.
func hide_actor() -> void:
	visible = false
	collision.collision_layer = 0
	process_mode = Node.PROCESS_MODE_DISABLED


func _play_locomotion() -> void:
	if walk_speed >= RUN_SPEED_THRESHOLD:
		_play(&"run", walk_speed / RUN_CYCLE_SPEED)
	else:
		_play(&"walk", walk_speed / WALK_CYCLE_SPEED)


func _play(animation: StringName, speed: float = 1.0) -> void:
	if _animation_player == null:
		return
	if not _animation_player.has_animation(animation):
		animation = &"idle"
	# Si ya suena, `play` la continúa y solo cambia la velocidad.
	_animation_player.play(animation, BLEND_SECONDS, speed)


## El glTF no guarda si una animación se repite, y el exportador añade un
## fotograma igual al primero: se marca el bucle y se recorta ese fotograma.
static func _prepare_loops(player: AnimationPlayer) -> void:
	for animation_name: StringName in LOOPED_ANIMATIONS:
		if not player.has_animation(animation_name):
			continue
		var animation: Animation = player.get_animation(animation_name)
		if animation.loop_mode == Animation.LOOP_LINEAR:
			continue
		animation.loop_mode = Animation.LOOP_LINEAR
		var last_key: float = 0.0
		for track: int in range(animation.get_track_count()):
			var count: int = animation.track_get_key_count(track)
			if count > 0:
				last_key = maxf(last_key, animation.track_get_key_time(track, count - 1))
		if last_key > 0.0:
			animation.length = last_key


func _setup_look(skeleton: Skeleton3D) -> void:
	if skeleton == null or skeleton.find_bone(HEAD_BONE) < 0:
		return
	_look_point = Marker3D.new()
	_look_point.name = "LookPoint"
	_look_point.top_level = true
	add_child(_look_point)
	_look = LookAtModifier3D.new()
	_look.name = "HeadLook"
	skeleton.add_child(_look)
	_look.bone_name = HEAD_BONE
	# En el esqueleto importado, la cara mira hacia −Z del hueso de la cabeza.
	_look.forward_axis = SkeletonModifier3D.BONE_AXIS_MINUS_Z
	_look.primary_rotation_axis = Vector3.AXIS_Y
	_look.use_angle_limitation = true
	_look.symmetry_limitation = true
	_look.primary_limit_angle = deg_to_rad(LOOK_YAW_LIMIT_DEGREES)
	_look.secondary_limit_angle = deg_to_rad(LOOK_PITCH_LIMIT_DEGREES)
	_look.duration = 0.25
	_look.transition_type = Tween.TRANS_SINE
	_look.target_node = _look.get_path_to(_look_point)
	_look.influence = 0.0


func _update_look(delta: float) -> void:
	if _look == null:
		return
	var wanted: float = 1.0 if wants_to_look() else 0.0
	if wanted > 0.0:
		_look_point.global_position = watch_target.global_position + Vector3.UP * LOOK_TARGET_HEIGHT
	_look.influence = move_toward(_look.influence, wanted, LOOK_FADE_PER_SECOND * delta)
	_look.active = _look.influence > 0.001
