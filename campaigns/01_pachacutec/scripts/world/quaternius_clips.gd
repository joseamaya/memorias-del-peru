class_name QuaterniusClips
extends RefCounted
## clips lógicos compartidos para los cuerpos Quaternius de 65 huesos.
##
## El GLB del personaje trae malla y esqueleto, pero no animaciones: este
## cargador copia una vez los clips de UAL1 y los añade al AnimationPlayer de
## cada personaje. Así no se duplican animaciones en cada GLB y el mismo clip
## sirve para todos los cuerpos.
##
## Los nombres lógicos son los que ya usa `NpcActor` (`idle`, `walk`, `run`…).
## No conoce campañas ni escenas.

const SOURCE_PATH: String = "res://shared_assets/characters/mannequin/ual1_standard.glb"
## Clip de UAL1 que alimenta cada acción del juego.
const SOURCE_CLIPS: Dictionary[StringName, StringName] = {
	&"idle": &"Idle",
	&"idle_b": &"Idle",
	&"walk": &"Walk",
	&"run": &"Jog_Fwd",
	&"talk": &"Idle_Talking",
	&"work": &"Fixing_Kneeling",
	&"weave": &"Fixing_Kneeling",
	&"tired": &"Crouch_Idle",
	&"attack": &"Sword_Attack",
	&"hit": &"Hit_Chest",
	&"death": &"Death01",
}
const LOOPED: Array[StringName] = [
	&"idle", &"idle_b", &"walk", &"run", &"talk", &"work", &"weave", &"tired",
]
const RIG_META: StringName = &"pch_rig"
const RIG_VALUE: String = "quaternius"

static var _cache: Dictionary[StringName, Animation] = {}


## Indica si [param model] es un cuerpo Quaternius. Se apoya en los extras
## glTF `pch_rig` y, como respaldo, en el hueso `hand_r` del esqueleto.
static func is_quaternius(model: Node) -> bool:
	if model == null:
		return false
	var nodes: Array[Node] = model.find_children("*", "", true, false)
	nodes.push_front(model)
	for node: Node in nodes:
		if not node.has_meta(&"extras"):
			continue
		var extras: String = str(node.get_meta(&"extras"))
		if extras.contains(str(RIG_META)) and extras.contains(RIG_VALUE):
			return true
	var skeleton: Skeleton3D = model.find_child("Skeleton3D", true, false) as Skeleton3D
	return skeleton != null and skeleton.find_bone("hand_r") >= 0


## Devuelve el AnimationPlayer del modelo, lo crea si falta y le añade los
## clips compartidos.
static func ensure_player(model: Node) -> AnimationPlayer:
	if model == null:
		return null
	var player: AnimationPlayer = model.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if player == null:
		player = AnimationPlayer.new()
		player.name = "AnimationPlayer"
		model.add_child(player)
	add_to(player)
	return player


## Devuelve el AnimationPlayer que toca para [param model]. En un cuerpo
## Quaternius crea el player si falta, añade los clips y aplica materiales;
## en un modelo heredado devuelve el player que ya traía.
static func player_for(model: Node, player: AnimationPlayer) -> AnimationPlayer:
	if not is_quaternius(model):
		return player
	if player == null:
		player = ensure_player(model)
	else:
		add_to(player)
	if DisplayServer.get_name() != "headless":
		SurfaceMaterials.apply_to_model(model)
	return player


## Añade los clips compartidos a [param player] sin duplicar los existentes.
static func add_to(player: AnimationPlayer) -> void:
	if player == null:
		return
	if _cache.is_empty():
		_load()
	var library: AnimationLibrary
	if player.has_animation_library(&""):
		library = player.get_animation_library(&"")
	else:
		library = AnimationLibrary.new()
		player.add_animation_library(&"", library)
	for clip: StringName in _cache:
		if not library.has_animation(clip):
			library.add_animation(clip, _cache[clip])


## Nombres disponibles, para las pruebas.
static func available() -> Array[StringName]:
	if _cache.is_empty():
		_load()
	return _cache.keys()


static func _load() -> void:
	if not ResourceLoader.exists(SOURCE_PATH):
		return
	var packed: PackedScene = load(SOURCE_PATH) as PackedScene
	if packed == null:
		return
	var holder: Node = packed.instantiate()
	var source: AnimationPlayer = holder.find_child("AnimationPlayer", true, false) as AnimationPlayer
	if source == null:
		holder.free()
		return
	for logical: StringName in SOURCE_CLIPS:
		var source_name: StringName = SOURCE_CLIPS[logical]
		if not source.has_animation(source_name):
			continue
		var clip: Animation = source.get_animation(source_name).duplicate() as Animation
		clip.resource_name = String(logical)
		_set_loop(clip, LOOPED.has(logical))
		_cache[logical] = clip
	holder.free()


## Los glTF no guardan el bucle: se marca y se recorta el fotograma duplicado
## del final, igual que hace `NpcActor._prepare_loops`.
static func _set_loop(clip: Animation, looped: bool) -> void:
	if not looped:
		return
	clip.loop_mode = Animation.LOOP_LINEAR
	var last_key: float = 0.0
	for track: int in range(clip.get_track_count()):
		var count: int = clip.track_get_key_count(track)
		if count > 0:
			last_key = maxf(last_key, clip.track_get_key_time(track, count - 1))
	if last_key > 0.0:
		clip.length = last_key
