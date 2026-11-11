extends RefCounted
## Comprueba que GraphicsSettings aplica los perfiles.
##
## La escala, el MSAA y el antialiasing se leen de vuelta del Viewport. El atlas
## de sombras direccionales no tiene getter en RenderingServer, así que se
## comprueba la copia que se rellena en la misma función que llama al motor.

var _signals: int = 0


func _on_profile_changed(_profile: GraphicsProfile) -> void:
	_signals += 1


func test_graphics_settings_apply() -> bool:
	var settings: GraphicsSettingsService = GraphicsSettings
	if settings == null:
		return false
	var low: GraphicsProfile = load("res://core/systems/graphics/profiles/low.tres") as GraphicsProfile
	var high: GraphicsProfile = load("res://core/systems/graphics/profiles/high.tres") as GraphicsProfile
	if low == null or high == null:
		return false
	settings.profile_changed.connect(_on_profile_changed)
	settings.set_profile(high)
	var viewport: Viewport = settings.get_viewport()
	var high_ok: bool = (
		settings.get_active_profile() == high
		and _signals >= 1
		and viewport != null
		and is_equal_approx(viewport.scaling_3d_scale, high.render_scale)
		and viewport.msaa_3d == high.msaa_3d
		and viewport.screen_space_aa == high.screen_space_aa
		and settings.last_applied_shadow_atlas_size == high.shadow_atlas_size
		and settings.last_applied_shadow_atlas_16bits
	)
	settings.set_profile(low)
	var low_ok: bool = (
		settings.get_active_profile() == low
		and viewport != null
		and is_equal_approx(viewport.scaling_3d_scale, low.render_scale)
		and settings.last_applied_shadow_atlas_size == low.shadow_atlas_size
	)
	settings.profile_changed.disconnect(_on_profile_changed)
	return high_ok and low_ok


func test_shadow_atlas_per_profile() -> bool:
	var settings: GraphicsSettingsService = GraphicsSettings
	if settings == null:
		return false
	var expected: Array[int] = []
	for path: String in GraphicsSettingsService.PROFILE_PATHS:
		var profile: GraphicsProfile = load(path) as GraphicsProfile
		if profile == null:
			return false
		expected.append(profile.shadow_atlas_size)
	for index: int in range(expected.size()):
		settings.set_profile_by_index(index)
		if settings.last_applied_shadow_atlas_size != expected[index]:
			return false
		if not settings.last_applied_shadow_atlas_16bits:
			return false
	settings.set_profile_by_index(0)
	return true
