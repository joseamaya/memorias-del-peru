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
		and profile.render_scale >= 1.0
	)
	ok = ok and GraphicsSettingsService.profile_index_from_args(PackedStringArray(["--profile=2"]), index) == 2
	ok = ok and GraphicsSettingsService.profile_index_from_args(PackedStringArray(["--profile=x"]), index) == index
	ok = ok and GraphicsSettingsService.profile_index_from_args(PackedStringArray(["--promo"]), index) == index
	return ok
