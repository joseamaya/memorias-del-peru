class_name CuscoSanctuary
extends RefCounted
## Santuario del sol del Cusco preimperial (PCH-027).
##
## Terraza de piedra con el recinto sagrado encima, al sur de la plaza y con la
## escalinata mirando a ella, como en el Cusco real. Es reconstrucción (R): la
## disposición concreta no está documentada. El basamento lo deja la ladera al
## extender la plataforma hasta el terreno. Vive en su propio script para que
## `CuscoBlockout` no pase del límite de líneas.

## Centro del santuario en coordenadas locales de S1. Al sur de la plaza.
const CENTER: Vector2 = Vector2(0.0, 86.0)
const PLATFORM_SIZE: Vector3 = Vector3(38.0, 0.6, 12.0)
const STONE: Color = Color(0.66, 0.62, 0.54)
## El recinto conserva el color sagrado; la plataforma es de piedra (PCH-027).
const GOLD: Color = Color(0.72, 0.58, 0.30)
const RAMP_SLOPE_DEGREES: float = 30.0
const RAMP_WIDTH: float = 5.0


## Construye el santuario bajo [param parent] y devuelve su etiqueta de POI.
##
## [param ground] es la altura del terreno en coordenadas locales del sector:
## `Callable(x: float, z: float) -> float`, la misma que usa el blockout.
static func build(parent: Node3D, ground: Callable) -> Label3D:
	var center: Vector3 = Vector3(CENTER.x, 0.0, CENTER.y)
	var base: float = _max_ground(ground, center.x, center.z, PLATFORM_SIZE) + 0.2
	var top: float = base + 0.6
	BlockoutKit.add_box(
		parent,
		PLATFORM_SIZE,
		Vector3(center.x, base + 0.3, center.z),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaPlataforma"
	)
	_build_ramp(parent, ground, center, top)
	# Muros perimetrales, justo dentro del borde de la terraza.
	BlockoutKit.add_box(
		parent,
		Vector3(34.0, 1.6, 0.8),
		Vector3(center.x, base + 1.4, center.z - 5.0),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		parent,
		Vector3(34.0, 1.6, 0.8),
		Vector3(center.x, base + 1.4, center.z + 5.0),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		parent,
		Vector3(0.8, 1.6, 12.0),
		Vector3(center.x - 17.0, base + 1.4, center.z),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		parent,
		Vector3(0.8, 1.6, 12.0),
		Vector3(center.x + 17.0, base + 1.4, center.z),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	# El recinto sobresale del muro perimetral: si queda a ras, desde la plaza
	# solo se ve una tapia y el santuario no se lee.
	BlockoutKit.add_box(
		parent,
		Vector3(12.0, 3.4, 8.0),
		Vector3(center.x, base + 1.7, center.z),
		GOLD,
		true,
		Basis.IDENTITY,
		"CoricanchaRecinto"
	)
	return BlockoutKit.add_label(
		parent, "POI-18 · Santuario del Sol", Vector3(center.x, base + 5.0, center.z)
	)


## Escalinata de acceso por el lado de la plaza. La pendiente se mide contra el
## terreno: un tramo fijo quedaba enterrado en la ladera.
static func _build_ramp(parent: Node3D, ground: Callable, center: Vector3, top: float) -> void:
	var start_z: float = center.z - PLATFORM_SIZE.z * 0.5
	var end_ground: float = _height(ground, center.x, start_z - 8.0)
	var drop: float = maxf(top - end_ground, 0.4)
	var length: float = clampf(drop / tan(deg_to_rad(RAMP_SLOPE_DEGREES)), 4.0, 12.0)
	var angle: float = atan2(drop, length)
	BlockoutKit.add_box(
		parent,
		Vector3(RAMP_WIDTH, 0.2, length),
		Vector3(center.x, top - drop * 0.5, start_z - length * 0.5),
		STONE,
		true,
		Basis(Vector3.RIGHT, -angle),
		"Rampa"
	)


## Altura del terreno en un punto local. El `Callable` devuelve `Variant`.
static func _height(ground: Callable, x: float, z: float) -> float:
	return str(ground.call(x, z)).to_float()


## Cota más alta de la huella: el centro y las cuatro esquinas.
static func _max_ground(ground: Callable, x: float, z: float, size: Vector3) -> float:
	var half_x: float = size.x * 0.5
	var half_z: float = size.z * 0.5
	var heights: Array[float] = [
		_height(ground, x, z),
		_height(ground, x - half_x, z - half_z),
		_height(ground, x + half_x, z - half_z),
		_height(ground, x - half_x, z + half_z),
		_height(ground, x + half_x, z + half_z),
	]
	var maximum: float = heights[0]
	for height: float in heights:
		maximum = maxf(maximum, height)
	return maximum
