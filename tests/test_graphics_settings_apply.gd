extends RefCounted
## Comprueba que GraphicsSettings aplica perfiles y emite la señal.

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
	var ok: bool = settings.get_active_profile() == high and _signals >= 1
	settings.set_profile(low)
	settings.profile_changed.disconnect(_on_profile_changed)
	return ok
