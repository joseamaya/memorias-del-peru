class_name SlingDrill
extends Node3D
## Entrenamiento de honda del acto I: un fardo de paja y tres tiros.
##
## Se instala en la plaza mientras el paso [constant SliceStep.Kind.DRILL]
## está activo. El jugador apunta con la vista y hace clic; el tiro cuenta si
## el centro de la pantalla cae dentro del cono del blanco. La piedra vuela,
## el fardo destella y el HUD lleva la cuenta. No conoce el flujo de la
## campaña: avisa con señales.

signal hit(progress: int, total: int)
signal completed

const TARGET_POSITION: Vector3 = Vector3(-2.0, 0.0, 4.0)
const TARGET_LAYER: int = 4
const BOARD_HEIGHT: float = 1.45
const BOARD_SIZE: float = 0.72
const AIM_CONE_DEGREES: float = 8.0
const MAX_RANGE: float = 18.0
const COOLDOWN_SECONDS: float = 0.45
const STONE_FLIGHT_SECONDS: float = 0.30
const STRAW_COLOR: Color = Color(0.68, 0.55, 0.30, 1.0)
const RING_COLOR: Color = Color(0.52, 0.20, 0.12, 1.0)
const STONE_COLOR: Color = Color(0.46, 0.44, 0.40, 1.0)

var _player: PlayerFPS = null
var _hud: PlayerHud = null
var _total: int = 0
var _progress: int = 0
var _active: bool = false
var _cooldown: float = 0.0

var _body: StaticBody3D = null
var _board: MeshInstance3D = null
var _board_material: StandardMaterial3D = null


## Monta el blanco y lo deja oculto. [param player] presta la cámara; [param hud]
## recibe las pistas de tiro.
func setup(player: PlayerFPS, hud: PlayerHud) -> void:
	_player = player
	_hud = hud
	name = "SlingDrill"
	position = TARGET_POSITION
	_build_target()
	stop()


## Empieza el ejercicio con [param needed] aciertos.
func start(needed: int) -> void:
	_total = maxi(needed, 1)
	_progress = 0
	_cooldown = 0.0
	_active = true
	visible = true
	if _body != null:
		_body.collision_layer = TARGET_LAYER
	if _hud != null:
		_hud.show_hint(tr("PCH_TRAIN_AIM"), 3.2)


## Detiene el ejercicio, retira el blanco y limpia la cuenta.
func stop() -> void:
	_active = false
	_progress = 0
	_cooldown = 0.0
	visible = false
	if _body != null:
		_body.collision_layer = 0


func is_active() -> bool:
	return _active


func progress() -> int:
	return _progress


func total() -> int:
	return _total


## Lanza una piedra desde la cámara. Devuelve si el centro de la vista cae en
## el cono del blanco; el proyectil y el aviso salen siempre.
func throw_stone() -> bool:
	if not _active or _player == null or _player.camera == null:
		return false
	var camera: Camera3D = _player.camera
	var origin: Vector3 = camera.global_position
	var forward: Vector3 = -camera.global_transform.basis.z
	var center: Vector3 = global_position + Vector3(0.0, BOARD_HEIGHT, 0.0)
	var to_target: Vector3 = center - origin
	var in_range: bool = to_target.length() <= MAX_RANGE
	var is_hit: bool = false
	if in_range and to_target.length_squared() > 0.0001:
		var angle: float = rad_to_deg(forward.angle_to(to_target.normalized()))
		is_hit = angle <= AIM_CONE_DEGREES
	var end: Vector3 = center if is_hit else origin + forward * MAX_RANGE
	_animate_weapon()
	_spawn_stone(origin + forward * 0.4, end)
	CampaignAudio.play_sfx(CampaignAudio.WHOOSH_PATH, -10.0)
	if is_hit:
		_register_hit()
	elif _hud != null:
		_hud.show_hint(tr("PCH_TRAIN_MISS" if in_range else "PCH_TRAIN_FAR"), 1.6)
	return is_hit


func _unhandled_input(event: InputEvent) -> void:
	if not _active or _cooldown > 0.0 or not event.is_action_pressed("attack"):
		return
	if _hud != null and (_hud.is_journal_open() or _hud.is_cinematic()):
		return
	_cooldown = COOLDOWN_SECONDS
	throw_stone()
	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if _cooldown > 0.0:
		_cooldown = maxf(_cooldown - delta, 0.0)


func _register_hit() -> void:
	_progress = mini(_progress + 1, _total)
	_flash_board()
	CampaignAudio.play_sfx(CampaignAudio.IMPACT_PATH, -8.0)
	if _hud != null:
		_hud.show_hint(tr("PCH_TRAIN_HIT") % [_progress, _total], 1.4)
	hit.emit(_progress, _total)
	if _progress >= _total:
		_active = false
		if _body != null:
			_body.collision_layer = 0
		completed.emit()


## Gesto de lanzamiento de la honda en primera persona.
func _animate_weapon() -> void:
	if _player == null:
		return
	var weapon: FirstPersonWeapon = _player.get_node_or_null(
		"Head/Camera3D/FirstPersonWeapon") as FirstPersonWeapon
	if weapon != null:
		weapon.play_attack()


func _spawn_stone(from: Vector3, to: Vector3) -> void:
	var parent: Node3D = get_parent() as Node3D
	if parent == null:
		return
	var stone: MeshInstance3D = MeshInstance3D.new()
	stone.name = "TrainingStone"
	var sphere: SphereMesh = SphereMesh.new()
	sphere.radius = 0.045
	sphere.height = 0.09
	sphere.radial_segments = 8
	sphere.rings = 4
	stone.mesh = sphere
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = STONE_COLOR
	material.roughness = 1.0
	stone.material_override = material
	stone.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	parent.add_child(stone)
	stone.global_position = from
	var mid: Vector3 = from.lerp(to, 0.5) + Vector3.UP * 0.28
	var half: float = STONE_FLIGHT_SECONDS * 0.5
	var tween: Tween = stone.create_tween()
	tween.tween_property(stone, "global_position", mid, half) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(stone, "global_position", to, half) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(stone.queue_free)


func _flash_board() -> void:
	if _board == null:
		return
	var flash: StandardMaterial3D = StandardMaterial3D.new()
	flash.albedo_color = Color(0.98, 0.84, 0.42, 1.0)
	flash.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_board.material_override = flash
	await get_tree().create_timer(0.16, false).timeout
	if is_instance_valid(_board):
		_board.material_override = _board_material


func _build_target() -> void:
	_body = StaticBody3D.new()
	_body.name = "TargetBody"
	_body.collision_layer = 0
	_body.collision_mask = 0
	add_child(_body)
	var shape: CollisionShape3D = CollisionShape3D.new()
	var box: BoxShape3D = BoxShape3D.new()
	box.size = Vector3(BOARD_SIZE + 0.2, 2.0, BOARD_SIZE + 0.2)
	shape.shape = box
	shape.position = Vector3(0.0, 1.0, 0.0)
	_body.add_child(shape)
	var post: MeshInstance3D = MeshInstance3D.new()
	var cylinder: CylinderMesh = CylinderMesh.new()
	cylinder.top_radius = 0.055
	cylinder.bottom_radius = 0.075
	cylinder.height = 1.1
	cylinder.radial_segments = 8
	post.mesh = cylinder
	var wood: StandardMaterial3D = StandardMaterial3D.new()
	wood.albedo_color = Color(0.38, 0.26, 0.16, 1.0)
	wood.roughness = 0.95
	post.material_override = wood
	post.position = Vector3(0.0, 0.55, 0.0)
	_body.add_child(post)
	_board = MeshInstance3D.new()
	_board.name = "StrawBale"
	var bale: BoxMesh = BoxMesh.new()
	bale.size = Vector3(BOARD_SIZE, BOARD_SIZE, BOARD_SIZE)
	_board.mesh = bale
	_board_material = StandardMaterial3D.new()
	_board_material.albedo_color = STRAW_COLOR
	_board_material.roughness = 1.0
	_board.material_override = _board_material
	_board.position = Vector3(0.0, BOARD_HEIGHT, 0.0)
	_body.add_child(_board)
	_add_ring(Vector3(0.0, BOARD_HEIGHT, BOARD_SIZE * 0.5 + 0.01), Vector3(90.0, 0.0, 0.0), 0.22)
	_add_ring(Vector3(0.0, BOARD_HEIGHT, -BOARD_SIZE * 0.5 - 0.01), Vector3(90.0, 0.0, 0.0), 0.22)
	_add_ring(Vector3(BOARD_SIZE * 0.5 + 0.01, BOARD_HEIGHT, 0.0), Vector3(0.0, 0.0, 90.0), 0.22)
	_add_ring(Vector3(-BOARD_SIZE * 0.5 - 0.01, BOARD_HEIGHT, 0.0), Vector3(0.0, 0.0, 90.0), 0.22)


## Disco oscuro de la diana, pegado a una cara del fardo.
func _add_ring(at: Vector3, tilt: Vector3, radius: float) -> void:
	var disk: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = 0.02
	mesh.radial_segments = 20
	disk.mesh = mesh
	disk.position = at
	disk.rotation_degrees = tilt
	var material: StandardMaterial3D = StandardMaterial3D.new()
	material.albedo_color = RING_COLOR
	material.roughness = 1.0
	disk.material_override = material
	_body.add_child(disk)
