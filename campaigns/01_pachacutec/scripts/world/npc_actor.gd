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
## Altura visible a la que se ajusta el modelo, en metros. Los GLB del elenco
## venían con alturas de 1,34 a 1,68 m y se notaba al lado del jugador (1,70).
## Con 0 no se escala: solo se apoyan los pies en el suelo (posturas sentadas).
@export var target_height: float = 0.0
## Variación de altura por personaje, para que el elenco no sea un molde.
@export var height_variation: float = 0.04

## A partir de esta velocidad corre en lugar de caminar.
const RUN_SPEED_THRESHOLD: float = 2.6
## Arranque, frenada y giro de una persona (no de golpe): aceleración y
## frenada en m/s², giro en grados por segundo, al caminar y al correr.
const WALK_ACCELERATION: float = 2.0
const RUN_ACCELERATION: float = 4.5
const WALK_TURN_RATE: float = 260.0
const RUN_TURN_RATE: float = 360.0
const IDLE_TURN_RATE: float = 200.0
## Por debajo de esta fracción de su velocidad, la animación no se frena más
## (andar a cámara lenta se ve raro): mejor un paso algo más corto.
const MIN_ANIMATION_RATE: float = 0.35
## Velocidad de desplazamiento de cada ciclo a velocidad de reproducción 1 y
## metros por paso. Los maniquíes UAL1 usan estos valores fijos.
const WALK_CYCLE_SPEED: float = 1.2
const RUN_CYCLE_SPEED: float = 3.0
const STRIDE_LENGTH: float = 0.66
const RUN_STRIDE_LENGTH: float = 1.1
const BLEND_SECONDS: float = 0.3
const LOOPED_ANIMATIONS: Array[StringName] = [&"idle", &"idle_b", &"walk", &"run", &"talk", &"tired", &"weave", &"work"]
## Correspondencia entre los nombres lógicos del juego y los clips del maniquí
## UAL1 (CC0). Los modelos propios usan sus propios nombres.
const MANNEQUIN_CLIPS: Dictionary[StringName, StringName] = {
	&"idle": &"Idle",
	&"idle_b": &"Idle",
	&"walk": &"Walk",
	&"run": &"Jog_Fwd",
	&"talk": &"Idle_Talking",
	&"tired": &"Crouch_Idle",
	&"weave": &"Fixing_Kneeling",
	&"work": &"Fixing_Kneeling",
}
## Variantes del reposo «idle»: se alternan cada IDLE_SWITCH_MIN–MAX segundos.
const IDLE_VARIANTS: Array[StringName] = [&"idle", &"idle_b"]
const IDLE_SWITCH_MIN: float = 6.0
const IDLE_SWITCH_MAX: float = 13.0
const IDLE_SWITCH_BLEND: float = 0.8
## Mirada: distancia máxima, ángulo de giro del cuello y rapidez del cambio.
const LOOK_RADIUS: float = 6.0
const LOOK_YAW_LIMIT_DEGREES: float = 140.0
const LOOK_PITCH_LIMIT_DEGREES: float = 50.0
const LOOK_FADE_PER_SECOND: float = 2.5
## Altura de los ojos del objetivo sobre su origen (el jugador mide 1,7 m).
const LOOK_TARGET_HEIGHT: float = 1.55
## Hueso de la cabeza: «Head» en el esqueleto Quaternius.
const HEAD_BONES: Array[String] = ["Head", "head"]
## Instante del golpe dentro de cada ciclo de trabajo, en segundos, si el
## modelo no trae el suyo (`pch_weave_beat`, `pch_work_beat`).
const ANIMATION_BEATS: Dictionary[StringName, float] = {&"weave": 0.6, &"work": 2.37}
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
var _skeleton: Skeleton3D = null
var _head_index: int = -1
var _perform_animation: StringName = &""
var _perform_left: float = 0.0
var _stride_distance: float = 0.0
## Velocidad actual (sube y baja poco a poco hasta walk_speed).
var _speed: float = 0.0
## Orientación buscada en planta, en radianes; se alcanza poco a poco.
var _target_yaw: float = 0.0
var _turning: bool = false
var _idle_switch_left: float = 0.0
var _idle_rng: RandomNumberGenerator = RandomNumberGenerator.new()
## Punto al que mirar al llegar, si se pidió mirar algo mientras caminaba.
var _arrival_face: Vector3 = Vector3.ZERO
var _has_arrival_face: bool = false
var _last_position: float = -1.0
var _steps_player: AudioStreamPlayer3D = null
var _step_streams: Array[AudioStream] = []
var _step_index: int = 0
var _beats: Dictionary[StringName, float] = ANIMATION_BEATS.duplicate()
var _mannequin: bool = false
var _current_logical: StringName = &""


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
	_animation_player = QuaterniusClips.player_for(
		model, model.find_child("AnimationPlayer", true, false) as AnimationPlayer)
	if _animation_player == null: return
	_fit_model(model)
	_mannequin = _animation_player.has_animation(&"Idle")
	_prepare_loops(_animation_player, _mannequin)
	if _mannequin:
		# UAL1 mira hacia +Z; el actor orienta su -Z hacia el objetivo. El giro
		# deja la cara del maniquí hacia delante sin tocar los clips.
		model.rotation.y = PI
		_set_mannequin_beats()
	_idle_rng.seed = hash(String(name))
	_idle_switch_left = _idle_rng.randf_range(IDLE_SWITCH_MIN, IDLE_SWITCH_MAX)
	if _idle_tween != null and _idle_tween.is_valid():
		_idle_tween.kill()
	body.position.y = 0.85
	body.visible = false
	var skeletons: Array[Node] = model.find_children("*", "Skeleton3D", true, false)
	if not skeletons.is_empty():
		_setup_look(skeletons[0] as Skeleton3D)
	_play(idle_animation)
	# Cada personaje empieza su reposo en un punto distinto del ciclo, para que
	# no respiren todos a la vez.
	var length: float = _animation_player.current_animation_length
	if length > 0.0:
		_animation_player.seek(fmod(float(absi(hash(String(name)))) * 0.618, 1.0) * length, true)


## Ajusta la altura del modelo y apoya sus pies en el suelo. La variación sale
## del nombre para que sea estable entre partidas y no cambie al recargar.
func _fit_model(model: Node3D) -> void:
	if target_height <= 0.0:
		ModelSlot.fit_height(model, 0.0)
		return
	# Variación estable a partir del nombre: el mismo personaje mide lo mismo
	# en cada partida.
	var jitter: float = float(absi(hash(String(name))) % 1000) / 1000.0 * 2.0 - 1.0
	ModelSlot.fit_height(model, target_height + jitter * height_variation)


## Indica si el personaje tiene modelo con animaciones.
func is_animated() -> bool:
	return _animation_player != null


## Animación que suena ahora (vacía si no hay modelo animado).
func current_animation() -> StringName:
	if _animation_player == null:
		return &""
	if _mannequin and _current_logical != &"":
		return _current_logical
	return StringName(_animation_player.current_animation)


## Velocidad de desplazamiento del ciclo de paseo o de carrera del modelo
## a velocidad de reproducción 1.
func cycle_speed(running: bool) -> float:
	return RUN_CYCLE_SPEED if running else WALK_CYCLE_SPEED


## Instante del golpe de [param animation] dentro de su ciclo (o -1).
func beat_time(animation: StringName) -> float:
	return _beats.get(animation, -1.0)


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
	if not moving:
		_speed = 0.0
	moving = true
	_perform_left = 0.0
	_has_arrival_face = false
	_aim(target)
	_play_locomotion()


## Se detiene donde está.
func stop() -> void:
	moving = false
	_speed = 0.0
	_stride_distance = 0.0
	_play(_perform_animation if _perform_left > 0.0 else idle_animation)


## Gira el cuerpo hacia un punto, sin inclinarlo. Por defecto gira poco a
## poco, como una persona; con [param instant], de golpe (al colocar).
##
## Si está caminando, mirará a ese punto al llegar: no camina de lado.
func face(point: Vector3, instant: bool = false) -> void:
	if moving and not instant:
		_arrival_face = point
		_has_arrival_face = true
		return
	if not _aim(point):
		return
	if instant:
		rotation.y = _target_yaw
		_turning = false
	else:
		_turning = true


## Fija la orientación buscada hacia [param point]. Devuelve `false` si el
## punto está encima del personaje.
func _aim(point: Vector3) -> bool:
	var flat: Vector3 = Vector3(point.x, global_position.y, point.z)
	if flat.is_equal_approx(global_position):
		return false
	var direction: Vector3 = (flat - global_position).normalized()
	_target_yaw = atan2(-direction.x, -direction.z)
	return true


## Velocidad actual en m/s.
func current_speed() -> float:
	return _speed


## Avanza hacia el destino. Devuelve `true` si acaba de llegar.
##
## Como una persona: acelera al arrancar, gira poco a poco hacia donde va (y
## frena si el giro es cerrado) y frena al acercarse al destino.
func advance(delta: float) -> bool:
	if not moving:
		return false
	var distance: float = global_position.distance_to(target)
	var running: bool = walk_speed >= RUN_SPEED_THRESHOLD
	var acceleration: float = RUN_ACCELERATION if running else WALK_ACCELERATION
	_aim(target)
	var heading_error: float = absf(_turn_towards_target(delta, RUN_TURN_RATE if running else WALK_TURN_RATE))
	var wanted: float = walk_speed * clampf(1.0 - heading_error / deg_to_rad(110.0), 0.3, 1.0)
	# Frenada: la velocidad que permite parar justo en el destino.
	wanted = minf(wanted, maxf(sqrt(2.0 * acceleration * distance), walk_speed * 0.12))
	_speed = move_toward(_speed, wanted, acceleration * delta)
	var step: float = _speed * delta
	if distance <= maxf(step, 0.02):
		global_position = target
		stop()
		if _has_arrival_face:
			_has_arrival_face = false
			face(_arrival_face)
		return true
	global_position = global_position.move_toward(target, step)
	_update_locomotion_rate()
	_stride_distance += step
	var stride: float = RUN_STRIDE_LENGTH if walk_speed >= RUN_SPEED_THRESHOLD else STRIDE_LENGTH
	if _stride_distance >= stride:
		_stride_distance -= stride
		stepped.emit()
	return false


func _process(delta: float) -> void:
	if _turning and not moving:
		_turn_towards_target(delta, IDLE_TURN_RATE)
	if _perform_left > 0.0:
		_perform_left -= delta
		if _perform_left <= 0.0 and not moving:
			_play(idle_animation)
	_update_look(delta)
	_check_beat()
	_vary_idle(delta)


## Quieto en el reposo general, cambia de cuando en cuando entre sus
## variantes con una mezcla lenta.
func _vary_idle(delta: float) -> void:
	if _mannequin or IDLE_VARIANTS.size() < 2:
		return
	if _animation_player == null or moving or _perform_left > 0.0 or idle_animation != &"idle":
		return
	var current: StringName = StringName(_animation_player.current_animation)
	if not IDLE_VARIANTS.has(current):
		return
	_idle_switch_left -= delta
	if _idle_switch_left > 0.0:
		return
	_idle_switch_left = _idle_rng.randf_range(IDLE_SWITCH_MIN, IDLE_SWITCH_MAX)
	var next: StringName = IDLE_VARIANTS[(IDLE_VARIANTS.find(current) + 1) % IDLE_VARIANTS.size()]
	if _animation_player.has_animation(next):
		_animation_player.speed_scale = 1.0
		_animation_player.play(next, IDLE_SWITCH_BLEND)


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


static func _clip_for(animation: StringName) -> StringName:
	return MANNEQUIN_CLIPS.get(animation, animation)


## El maniquí no trae los extras de ritmo de los modelos propios: el golpe de
## trabajo se coloca a mitad del ciclo de `Fixing_Kneeling`.
func _set_mannequin_beats() -> void:
	var weave_clip: StringName = &"weave"
	if not _animation_player.has_animation(weave_clip):
		weave_clip = &"Fixing_Kneeling"
	var work_clip: StringName = &"work"
	if not _animation_player.has_animation(work_clip):
		work_clip = &"Fixing_Kneeling"
	for logical: StringName in [&"weave", &"work"]:
		var clip: StringName = weave_clip if logical == &"weave" else work_clip
		if not _animation_player.has_animation(clip):
			continue
		var length: float = _animation_player.get_animation(clip).length
		if length > 0.0:
			_beats[logical] = length * 0.5


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
	var animation: StringName = current_animation()
	if not _beats.has(animation):
		_last_position = -1.0
		return
	var playback: float = _animation_player.current_animation_position
	var at: float = _beats[animation]
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


## Punto al que mirar para encuadrar la cara en un diálogo. Sale del hueso de
## la cabeza, así que sirve igual para un personaje de pie que para la tejedora
## arrodillada: no hay una altura fija que valga para todos.
func focus_point() -> Vector3:
	if _skeleton != null and _head_index >= 0 and _skeleton.is_inside_tree():
		var head_pose: Transform3D = _skeleton.global_transform * _skeleton.get_bone_global_pose(_head_index)
		return head_pose.origin + Vector3.UP * 0.12
	return global_position + Vector3.UP * LOOK_TARGET_HEIGHT


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


## Gira hacia [member _target_yaw] a [param degrees_per_second]. Devuelve
## el ángulo que aún falta (con signo).
func _turn_towards_target(delta: float, degrees_per_second: float) -> float:
	var remaining: float = wrapf(_target_yaw - rotation.y, -PI, PI)
	var step: float = deg_to_rad(degrees_per_second) * delta
	if absf(remaining) <= step:
		rotation.y = _target_yaw
		_turning = false
		return 0.0
	rotation.y += signf(remaining) * step
	return remaining - signf(remaining) * step


func _play_locomotion() -> void:
	_play(&"run" if walk_speed >= RUN_SPEED_THRESHOLD else &"walk")
	_update_locomotion_rate()


## La animación avanza a la velocidad real: los pies no patinan aunque el
## personaje esté acelerando o frenando.
func _update_locomotion_rate() -> void:
	if _animation_player == null:
		return
	var cycle: float = RUN_CYCLE_SPEED if walk_speed >= RUN_SPEED_THRESHOLD else WALK_CYCLE_SPEED
	_animation_player.speed_scale = _locomotion_rate(cycle)


func _locomotion_rate(cycle: float) -> float:
	return maxf(_speed, walk_speed * MIN_ANIMATION_RATE) / maxf(cycle, 0.01)


func _play(animation: StringName, speed: float = 1.0) -> void:
	if _animation_player == null:
		return
	# El maniquí recibe los clips lógicos de `QuaterniusClips`; así usa el
	# `work` de UAL2 y conserva el mismo nombre que el elenco anterior. Si
	# falta, cae al clip nativo del UAL1.
	var clip: StringName = animation
	if _mannequin and not _animation_player.has_animation(clip):
		clip = _clip_for(animation)
	if not _animation_player.has_animation(clip):
		clip = &"idle" if _animation_player.has_animation(&"idle") else _clip_for(&"idle")
	# Si ya suena, `play` la continúa y solo cambia la velocidad. La escala
	# general solo la usa la locomoción (_update_locomotion_rate).
	_animation_player.speed_scale = 1.0
	_animation_player.play(clip, BLEND_SECONDS, speed)
	_current_logical = animation


## El glTF no guarda si una animación se repite, y el exportador añade un
## fotograma igual al primero: se marca el bucle y se recorta ese fotograma.
static func _prepare_loops(player: AnimationPlayer, mannequin: bool = false) -> void:
	for logical_name: StringName in LOOPED_ANIMATIONS:
		var animation_name: StringName = _clip_for(logical_name) if mannequin else logical_name
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


## Eje del hueso [param bone] que apunta hacia delante del personaje en la
## pose de reposo (la cara, en el hueso de la cabeza).
func _forward_axis(skeleton: Skeleton3D, bone: int) -> SkeletonModifier3D.BoneAxis:
	var bone_basis: Basis = (skeleton.global_transform * skeleton.get_bone_global_rest(bone)).basis.orthonormalized()
	var forward: Vector3 = -global_transform.basis.z.normalized()
	var axes: Array[Vector3] = [bone_basis.x, -bone_basis.x, bone_basis.y, -bone_basis.y, bone_basis.z, -bone_basis.z]
	var best: int = 0
	for index: int in range(axes.size()):
		if axes[index].dot(forward) > axes[best].dot(forward):
			best = index
	return best as SkeletonModifier3D.BoneAxis


func _setup_look(skeleton: Skeleton3D) -> void:
	if skeleton == null:
		return
	var head_bone: String = ""
	for candidate: String in HEAD_BONES:
		if skeleton.find_bone(candidate) >= 0:
			head_bone = candidate
			break
	if head_bone.is_empty():
		return
	_skeleton = skeleton
	_head_index = skeleton.find_bone(head_bone)
	_look_point = Marker3D.new()
	_look_point.name = "LookPoint"
	_look_point.top_level = true
	add_child(_look_point)
	_look = LookAtModifier3D.new()
	_look.name = "HeadLook"
	skeleton.add_child(_look)
	_look.bone_name = head_bone
	# El eje de la cara depende del esqueleto importado: se busca el que mira
	# hacia delante en la pose de reposo.
	_look.forward_axis = _forward_axis(skeleton, skeleton.find_bone(head_bone))
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
