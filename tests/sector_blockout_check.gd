extends SceneTree
## Comprueba el blockout de F1.7: casas y pircas Cyclops, multitud MultiMesh,
## vegetación, navmesh con obstáculos y los 60 NPC.

const SCENE_PATH: String = "res://tests/scenes/sector_blockout.tscn"


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("BLOCKOUT_FAIL no scene")
		quit(1)
		return
	var sector: GreySector = packed.instantiate() as GreySector
	root.add_child(sector)
	sector.set_npc_autostart(false)
	sector.set_process(false)
	for _i: int in 20:
		await physics_frame
	var blockout: GreyBlockout = sector.get_blockout()
	var ok: bool = sector.get_npc_count() == 60 and blockout != null
	print("DEBUG npc=", sector.get_npc_count(), " blockout=", blockout != null)
	print(
		"DEBUG houses=",
		blockout.get_house_count(),
		" crowd=",
		blockout.get_crowd_count(),
		" veg=",
		blockout.get_vegetation_count()
	)
	print(
		"DEBUG active=",
		sector.get_active_npc_count(),
		" animated=",
		sector.get_animated_npc_count()
	)
	var nav_ok: bool = _check_navmesh(sector)
	print("DEBUG nav=", nav_ok)
	ok = ok and blockout.get_house_count() == 6
	ok = ok and blockout.get_crowd_count() == 120
	ok = ok and blockout.get_vegetation_count() == 180
	ok = ok and sector.get_active_npc_count() == 60
	ok = ok and sector.get_animated_npc_count() == 25
	ok = ok and _check_navmesh(sector)
	var active: int = sector.get_active_npc_count()
	var animated: int = sector.get_animated_npc_count()
	sector.queue_free()
	await process_frame
	if ok:
		print(
			"BLOCKOUT_OK npcs=60 houses=6 crowd=120 vegetation=180 active=",
			active,
			" animated=",
			animated
		)
	else:
		printerr("BLOCKOUT_FAIL")
	quit(0 if ok else 1)


## La casa de (−22, 6) recorta el navmesh: la ruta recta debe rodearla.
func _check_navmesh(sector: GreySector) -> bool:
	var path: PackedVector3Array = sector.get_navmesh_path(
		Vector3(-30.0, 0.0, 6.0), Vector3(-14.0, 0.0, 6.0)
	)
	if path.size() < 2:
		return false
	var detour: bool = false
	for point: Vector3 in path:
		if absf(point.z - 6.0) >= 2.0:
			detour = true
	return detour
