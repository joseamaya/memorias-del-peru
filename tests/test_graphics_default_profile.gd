extends RefCounted
## Comprueba el perfil con el que arranca el juego y el argumento que lo cambia.


func test_graphics_default_profile_is_medium() -> bool:
	var index: int = GraphicsSettingsService.DEFAULT_PROFILE_INDEX
	var path: String = GraphicsSettingsService.PROFILE_PATHS[index]
	var profile: GraphicsProfile = load(path) as GraphicsProfile
	var ok: bool = (
		index == 1
		and profile != null
		and profile.profile_name == "Medio"
		and profile.ssao_enabled
		# El 3D se renderiza por debajo de 1080p para cumplir los 60 FPS en la
		# GPU integrada; se conserva el SSAO y se baja la escala a 0,70
		# (docs/08 §2 y §4). La interfaz sigue a resolución completa.
		and profile.render_scale >= 0.65
		and profile.render_scale < 0.8
	)
	ok = ok and GraphicsSettingsService.profile_index_from_args(PackedStringArray(["--profile=2"]), index) == 2
	ok = ok and GraphicsSettingsService.profile_index_from_args(PackedStringArray(["--profile=x"]), index) == index
	ok = ok and GraphicsSettingsService.profile_index_from_args(PackedStringArray(["--promo"]), index) == index
	return ok
