extends RefCounted
## Comprueba que los cuatro perfiles cargan con sus valores clave.

const LOW: String = "res://core/systems/graphics/profiles/low.tres"
const MEDIUM: String = "res://core/systems/graphics/profiles/medium.tres"
const HIGH: String = "res://core/systems/graphics/profiles/high.tres"
const ULTRA: String = "res://core/systems/graphics/profiles/ultra.tres"


func test_graphics_profiles_load() -> bool:
	var low: GraphicsProfile = load(LOW) as GraphicsProfile
	var medium: GraphicsProfile = load(MEDIUM) as GraphicsProfile
	var high: GraphicsProfile = load(HIGH) as GraphicsProfile
	var ultra: GraphicsProfile = load(ULTRA) as GraphicsProfile
	if low == null or medium == null or high == null or ultra == null:
		return false
	return (
		not low.volumetric_fog_enabled
		and not medium.volumetric_fog_enabled
		and high.volumetric_fog_enabled
		and ultra.volumetric_fog_enabled
		and not low.ssao_enabled
		and medium.ssao_enabled
		and high.ssao_enabled
		and ultra.sdfgi_enabled
	)
