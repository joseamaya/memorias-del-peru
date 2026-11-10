class_name GraphicsSettingsService
extends Node
## Autoload de perfiles gráficos.
##
## Carga los perfiles, aplica los ajustes globales de Viewport y notifica a los
## controladores de cada mundo mediante [signal profile_changed].

signal profile_changed(profile: GraphicsProfile)

const PROFILE_PATHS: Array[String] = [
	"res://core/systems/graphics/profiles/low.tres",
	"res://core/systems/graphics/profiles/medium.tres",
	"res://core/systems/graphics/profiles/high.tres",
	"res://core/systems/graphics/profiles/ultra.tres",
]

var _profiles: Array[GraphicsProfile] = []
var _active_index: int = 0


func _ready() -> void:
	for path: String in PROFILE_PATHS:
		var profile: GraphicsProfile = load(path) as GraphicsProfile
		if profile != null:
			_profiles.append(profile)
	if not _profiles.is_empty():
		set_profile_by_index(0)


## Devuelve el perfil activo, o null si no hay perfiles cargados.
func get_active_profile() -> GraphicsProfile:
	if _profiles.is_empty():
		return null
	return _profiles[_active_index]


## Devuelve el índice del perfil activo.
func get_active_index() -> int:
	return _active_index


## Aplica un perfil concreto y emite la señal.
func set_profile(profile: GraphicsProfile) -> void:
	if profile == null:
		return
	var index: int = _profiles.find(profile)
	if index < 0:
		_profiles.append(profile)
		index = _profiles.size() - 1
	_apply(profile, index)


## Aplica el perfil por índice.
func set_profile_by_index(index: int) -> void:
	if _profiles.is_empty():
		return
	var safe_index: int = clampi(index, 0, _profiles.size() - 1)
	_apply(_profiles[safe_index], safe_index)


## Pasa al siguiente perfil de la lista.
func cycle_profile() -> void:
	if _profiles.is_empty():
		return
	set_profile_by_index((_active_index + 1) % _profiles.size())


func _apply(profile: GraphicsProfile, index: int) -> void:
	_active_index = index
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.scaling_3d_scale = profile.render_scale
		viewport.msaa_3d = profile.msaa_3d
		viewport.screen_space_aa = profile.screen_space_aa
	profile_changed.emit(profile)
