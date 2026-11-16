extends RefCounted
## Contrato de las paletas de acto: se aplican al cielo, al sol y al ambiente,
## y los cinco recursos de la campaña existen y no son iguales entre sí.


func test_palette_applies_sun_ambient_and_fog() -> bool:
	var palette: PaletteTuning = PaletteTuning.new()
	palette.sun_color = Color(1.0, 0.5, 0.25, 1.0)
	palette.sun_energy = 1.7
	palette.sun_elevation_deg = -15.0
	palette.sun_azimuth_deg = -30.0
	palette.ambient_color = Color(0.4, 0.5, 0.6, 1.0)
	palette.ambient_energy = 0.8
	palette.ambient_sky_contribution = 0.3
	palette.fog_color = Color(0.7, 0.8, 0.9, 1.0)
	palette.fog_density = 0.004
	palette.fog_height = 12.0
	palette.fog_height_density = 0.08
	palette.exposure = 1.2
	palette.contrast = 1.1
	palette.saturation = 0.9
	palette.background_energy = 0.7

	var environment: Environment = Environment.new()
	var sky_material: PhysicalSkyMaterial = PhysicalSkyMaterial.new()
	var sky: Sky = Sky.new()
	sky.sky_material = sky_material
	environment.sky = sky
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	world_environment.environment = environment
	var sun: DirectionalLight3D = DirectionalLight3D.new()

	palette.apply_to(world_environment, sun)

	var ok: bool = sun.light_color.is_equal_approx(Color(1.0, 0.5, 0.25, 1.0))
	ok = ok and is_equal_approx(sun.light_energy, 1.7)
	ok = ok and sun.rotation_degrees.is_equal_approx(Vector3(-15.0, -30.0, 0.0))
	ok = ok and environment.ambient_light_color.is_equal_approx(Color(0.4, 0.5, 0.6, 1.0))
	ok = ok and is_equal_approx(environment.ambient_light_energy, 0.8)
	ok = ok and is_equal_approx(environment.ambient_light_sky_contribution, 0.3)
	ok = ok and environment.fog_light_color.is_equal_approx(Color(0.7, 0.8, 0.9, 1.0))
	ok = ok and is_equal_approx(environment.fog_density, 0.004)
	ok = ok and is_equal_approx(environment.fog_height, 12.0)
	ok = ok and is_equal_approx(environment.fog_height_density, 0.08)
	ok = ok and is_equal_approx(environment.tonemap_exposure, 1.2)
	ok = ok and is_equal_approx(environment.adjustment_contrast, 1.1)
	ok = ok and is_equal_approx(environment.adjustment_saturation, 0.9)
	ok = ok and is_equal_approx(environment.background_energy_multiplier, 0.7)
	ok = ok and sky_material.rayleigh_color.is_equal_approx(palette.sky_rayleigh)
	ok = ok and sky_material.ground_color.is_equal_approx(palette.sky_ground)
	ok = ok and is_equal_approx(sky_material.turbidity, palette.sky_turbidity)

	world_environment.free()
	sun.free()
	return ok


func test_palette_creates_environment_when_missing() -> bool:
	var palette: PaletteTuning = PaletteTuning.new()
	var world_environment: WorldEnvironment = WorldEnvironment.new()
	var sun: DirectionalLight3D = DirectionalLight3D.new()
	palette.apply_to(world_environment, sun)
	var ok: bool = world_environment.environment != null
	ok = ok and world_environment.environment.fog_enabled
	world_environment.free()
	sun.free()
	return ok


func test_campaign_palettes_load_and_differ() -> bool:
	var paths: Array[String] = [
		"res://campaigns/01_pachacutec/resources/palettes/paleta_llacta.tres",
		"res://campaigns/01_pachacutec/resources/palettes/paleta_paso.tres",
		"res://campaigns/01_pachacutec/resources/palettes/paleta_ciudad.tres",
		"res://campaigns/01_pachacutec/resources/palettes/paleta_posguerra.tres",
		"res://campaigns/01_pachacutec/resources/palettes/paleta_obra.tres",
	]
	var names: Dictionary[String, bool] = {}
	var colors: Dictionary[Color, bool] = {}
	var ok: bool = true
	for path: String in paths:
		var palette: PaletteTuning = load(path) as PaletteTuning
		ok = ok and palette != null
		if palette == null:
			continue
		ok = ok and not palette.display_name.is_empty()
		names[palette.display_name] = true
		colors[palette.sun_color] = true
	ok = ok and names.size() == paths.size()
	ok = ok and colors.size() >= 3
	return ok
