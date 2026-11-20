extends SceneTree
## Comprueba el relieve regional de blockout: seis sectores con alturas
## plausibles, rango de cumbres y cauce por debajo de la vega.

const SCENE_PATH: String = "res://campaigns/01_pachacutec/scenes/world/region.tscn"
const HEIGHT_RANGES: Dictionary[StringName, Vector2] = {
	&"s1_cusco": Vector2(3380.0, 3500.0),
	&"s2_afueras": Vector2(3400.0, 3550.0),
	&"s3_llacta": Vector2(3500.0, 3700.0),
	&"s4_quebrada": Vector2(3800.0, 4050.0),
	&"s5_paso": Vector2(4000.0, 4300.0),
	&"s6_frontera": Vector2(3900.0, 4250.0),
}


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		printerr("REGION_FAIL no scene")
		quit(1)
		return
	var region: CampaignRegion = packed.instantiate() as CampaignRegion
	root.add_child(region)
	for _i: int in 3:
		await process_frame
	var terrain: Terrain3D = region.get_terrain()
	var ok: bool = terrain != null and terrain.data != null
	ok = ok and terrain.data.get_region_count() > 0
	ok = ok and region.get_sector_centers().size() == 6
	for id: StringName in HEIGHT_RANGES.keys():
		var height: float = region.get_sector_height(id)
		var range_values: Vector2 = HEIGHT_RANGES[id]
		if height < range_values.x or height > range_values.y:
			printerr("REGION_FAIL sector=", id, " height=", height)
			ok = false
	ok = ok and _check_relief(terrain)
	ok = ok and _check_river(region)
	var water: MeshInstance3D = region.get_water_mesh()
	var river_width: float = region.get_river_width()
	if water == null or water.mesh == null:
		ok = false
	else:
		ok = ok and river_width >= 6.0
		ok = ok and water.mesh.get_aabb().size.x > 2000.0
	ok = ok and _check_water_banks(region)
	print(
		"REGION build_ms=",
		region.get_build_ms(),
		" regions=",
		terrain.data.get_region_count(),
		" s1=",
		int(region.get_sector_height(&"s1_cusco")),
		" s3=",
		int(region.get_sector_height(&"s3_llacta")),
		" s5=",
		int(region.get_sector_height(&"s5_paso")),
		" river_width=",
		snappedf(river_width, 0.1)
	)
	region.queue_free()
	await process_frame
	if ok:
		print("REGION_OK sectors=6")
	else:
		printerr("REGION_FAIL")
	quit(0 if ok else 1)


func _check_water_banks(region: CampaignRegion) -> bool:
	for x: float in [-1000.0, -500.0, 0.0, 500.0, 1000.0]:
		var z: float = region.get_river_z(x)
		var water: float = region.get_river_surface_height(x)
		var center: float = region.height_at(x, z)
		var left: float = region.height_at(x, z - 6.5)
		var right: float = region.height_at(x, z + 6.5)
		if water < center + 0.05:
			return false
		if water > maxf(left, right) + 0.5:
			return false
	return true


func _check_relief(terrain: Terrain3D) -> bool:
	var minimum: float = INF
	var maximum: float = -INF
	for x: float in range(-1750.0, 1751.0, 100.0):
		for z: float in range(-1250.0, 1251.0, 100.0):
			var height: float = terrain.data.get_height(Vector3(x, 0.0, z))
			minimum = minf(minimum, height)
			maximum = maxf(maximum, height)
	var ok: bool = minimum > 3300.0 and minimum < 3500.0
	ok = ok and maximum > 4500.0 and maximum < 4900.0
	return ok


func _check_river(region: CampaignRegion) -> bool:
	var river: float = region.height_at(0.0, 260.0)
	var vega: float = region.height_at(0.0, 420.0)
	return river < vega - 3.0
