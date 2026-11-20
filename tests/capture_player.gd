extends Node
## Captura la vista del jugador en el mundo regional.
##
##   godot --path . --resolution 1280x720 res://tests/scenes/capture_player.tscn

const WORLD_SCENE: String = "res://campaigns/01_pachacutec/scenes/world/region_world.tscn"
const WARMUP_FRAMES: int = 90
## Quince segundos acercan la plaza y permiten ver el borde y el camino sin
## quedar dentro de la malla; la toma sirve para leer escala y acceso.
const WALK_FRAMES: int = 900


func _ready() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(WORLD_SCENE) as PackedScene
	if packed == null:
		printerr("PLAYER_CAPTURE_FAIL scene")
		get_tree().quit(1)
		return
	var world: RegionWorld = packed.instantiate() as RegionWorld
	add_child(world)
	for _i: int in WARMUP_FRAMES:
		await get_tree().process_frame
	_report_position(world, "inicio")
	var ok: bool = await _save("res://build/evidencia/region_player.png")
	Input.action_press("move_forward")
	for _i: int in WALK_FRAMES:
		await get_tree().physics_frame
	Input.action_release("move_forward")
	for _i: int in 4:
		await get_tree().process_frame
	_report_position(world, "plaza")
	ok = ok and await _save("res://build/evidencia/region_player_plaza.png")
	get_tree().quit(0 if ok else 1)


func _report_position(world: RegionWorld, label: String) -> void:
	var player: PlayerFPS = world.get_player()
	var region: CampaignRegion = world.get_region()
	if player == null or region == null:
		print("PLAYER_POS ", label, " sin jugador o región")
		return
	var at: Vector3 = player.global_position
	var ground: float = region.height_at(at.x, at.z)
	print(
		"PLAYER_POS ",
		label,
		" x=",
		snappedf(at.x, 0.1),
		" y=",
		snappedf(at.y, 0.1),
		" z=",
		snappedf(at.z, 0.1),
		" ground=",
		snappedf(ground, 0.1),
		" gap=",
		snappedf(at.y - ground, 0.1),
		" floor=",
		player.is_on_floor()
	)


func _save(path: String) -> bool:
	await RenderingServer.frame_post_draw
	var image: Image = get_viewport().get_texture().get_image()
	var absolute: String = ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute.get_base_dir())
	var error: Error = image.save_png(absolute)
	if error == OK:
		print("PLAYER_CAPTURE_OK path=", absolute)
		return true
	printerr("PLAYER_CAPTURE_FAIL error=", error)
	return false
