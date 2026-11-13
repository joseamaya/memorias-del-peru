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

## Perfil con el que arranca el juego.
##
## Es el perfil Medio: el juego se percibe mucho mejor con oclusión ambiental y
## sin reducción de escala, y el margen de rendimiento medido lo permite
## (docs/08 §4). Bajo sigue disponible en el ciclo de desarrollo con F2 y en la
## línea de comandos (`--profile`).
const DEFAULT_PROFILE_INDEX: int = 1

## Los perfiles usan el atlas de sombras direccionales de 16 bits.
##
## El segundo parámetro de [method RenderingServer.directional_shadow_atlas_set_size]
## es `is_16bits`, no "alta calidad": pasar `false` cambia el atlas a 32 bits,
## que duplica la memoria y el coste de sombreado sin mejorar la imagen de forma
## perceptible en la referencia con GPU integrada (docs/08 §2).
const SHADOW_ATLAS_16_BITS: bool = true

## Prefijo del argumento de línea de comandos que elige el perfil inicial.
const PROFILE_ARG: String = "--profile="

var _profiles: Array[GraphicsProfile] = []
var _active_index: int = 0

## Valores enviados al motor en la última aplicación del perfil.
##
## [RenderingServer] no expone un getter del atlas de sombras direccionales, de
## modo que estas copias son el único punto de observación verificable: reflejan
## lo que el autoload ordenó al motor, no el estado interno del renderizador.
var last_applied_shadow_atlas_size: int = 0
var last_applied_shadow_atlas_16bits: bool = SHADOW_ATLAS_16_BITS


func _ready() -> void:
	for path: String in PROFILE_PATHS:
		var profile: GraphicsProfile = load(path) as GraphicsProfile
		if profile != null:
			_profiles.append(profile)
	if not _profiles.is_empty():
		var requested: int = profile_index_from_args(OS.get_cmdline_user_args(), DEFAULT_PROFILE_INDEX)
		set_profile_by_index(requested)


## Lee el perfil pedido en la línea de comandos (`--profile=2`, después de `--`).
## Devuelve [param fallback] si no hay argumento o no es un entero válido.
static func profile_index_from_args(args: PackedStringArray, fallback: int) -> int:
	for arg: String in args:
		if not arg.begins_with(PROFILE_ARG):
			continue
		var value: String = arg.substr(PROFILE_ARG.length())
		if value.is_valid_int():
			return maxi(value.to_int(), 0)
	return fallback


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
	RenderingServer.directional_shadow_atlas_set_size(profile.shadow_atlas_size, SHADOW_ATLAS_16_BITS)
	RenderingServer.directional_soft_shadow_filter_set_quality(profile.shadow_filter_quality)
	last_applied_shadow_atlas_size = profile.shadow_atlas_size
	last_applied_shadow_atlas_16bits = SHADOW_ATLAS_16_BITS
	profile_changed.emit(profile)
