class_name LlactaBlockout
extends Node3D
## Blockout de S3 — Llacta de Rumi.
##
## Geometría gris de blockout: plaza, 16 casas, casa de Rumi, manantial,
## acequia, telar, corral, huerto y fogón. No es arte final ni contenido
## definitivo; las casas se convertirán a malla y colisión propias en F3.

const PLAZA_RADIUS: float = 18.0
const OUTER_RADIUS: float = 34.0
const INNER_RADIUS: float = 23.0
const HOUSE_SIZE: Vector3 = Vector3(6.0, 2.6, 4.5)
const CASA_RUMI_SIZE: Vector3 = Vector3(7.0, 2.8, 5.0)

const OUTER_ANGLES: Array[float] = [
	15.0, 65.0, 80.0, 110.0, 135.0, 170.0, 190.0, 220.0, 250.0, 280.0, 310.0, 340.0
]
const INNER_ANGLES: Array[float] = [95.0, 205.0, 235.0, 295.0]

const STONE: Color = Color(0.62, 0.58, 0.50)
const WALL: Color = Color(0.74, 0.68, 0.56)
const ROOF: Color = Color(0.42, 0.34, 0.25)
const SOIL: Color = Color(0.38, 0.30, 0.20)
const WATER: Color = Color(0.30, 0.48, 0.58)
const WOOD: Color = Color(0.36, 0.28, 0.20)

var _region: CampaignRegion = null
var _house_positions: PackedVector3Array = PackedVector3Array()
var _poi_labels: Array[Label3D] = []
var _house_count: int = 0


func _ready() -> void:
	_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	if _region == null:
		push_error("LlactaBlockout: falta el terreno regional.")
		return
	_build_plaza()
	_build_houses()
	_build_casa_rumi()
	_build_manantial()
	_build_acequia()
	_build_corral()
	_build_telar()
	_build_huerto()
	_build_horno()
	_build_fogon()
	_add_label(
		"POI-06 · Casa del curaca",
		Vector3(
			cos(deg_to_rad(80.0)) * OUTER_RADIUS,
			_ground(0.0, 0.0) + 6.0,
			sin(deg_to_rad(80.0)) * OUTER_RADIUS
		)
	)


func get_house_count() -> int:
	return _house_count


func get_poi_count() -> int:
	return _poi_labels.size()


func get_mesh_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()


func get_collision_count() -> int:
	return find_children("*", "StaticBody3D", true, false).size()


func get_house_positions() -> PackedVector3Array:
	return _house_positions


func _build_plaza() -> void:
	var ground: float = _max_ground(0.0, 0.0, Vector3(PLAZA_RADIUS * 2.0, 0.0, PLAZA_RADIUS * 2.0))
	# Losa fina, no un cilindro macizo: el blockout no tiene colisión en la
	# plaza y el jugador puede atravesarla. Con 0,8 m la cámara quedaba dentro
	# del volumen y solo se veía la cara interior.
	var plaza: MeshInstance3D = _cylinder(PLAZA_RADIUS, 0.12, Vector3(0.0, ground + 0.06, 0.0))
	plaza.name = "Plaza"
	_add_label("POI-02 · Plaza de la llacta", Vector3(0.0, ground + 3.5, 0.0))


func _build_houses() -> void:
	for index: int in OUTER_ANGLES.size():
		_house(OUTER_ANGLES[index], OUTER_RADIUS, HOUSE_SIZE, "")
	for index: int in INNER_ANGLES.size():
		_house(INNER_ANGLES[index], INNER_RADIUS, HOUSE_SIZE, "")


func _build_casa_rumi() -> void:
	_house(0.0, OUTER_RADIUS + 2.0, CASA_RUMI_SIZE, "POI-01 · Casa de Rumi")


func _house(angle_degrees: float, radius: float, size: Vector3, label: String) -> void:
	var radians: float = deg_to_rad(angle_degrees)
	var x: float = cos(radians) * radius
	var z: float = sin(radians) * radius
	var ground: float = _max_ground(x, z, size)
	var orientation: Basis = Basis(Vector3.UP, -radians + PI * 0.5)
	_add_box(
		Vector3(size.x + 0.4, 0.4, size.z + 0.4),
		Vector3(x, ground - 0.2, z),
		STONE,
		false,
		orientation,
		"Foundation"
	)
	_add_box(size, Vector3(x, ground + size.y * 0.5, z), WALL, true, orientation, "Casa")
	_add_box(
		Vector3(size.x + 0.8, 0.35, size.z + 0.7),
		Vector3(x, ground + size.y + 0.175, z),
		ROOF,
		false,
		orientation,
		"Techo"
	)
	if not label.is_empty():
		_add_label(label, Vector3(x, ground + size.y + 3.2, z))
	_house_positions.append(Vector3(x, ground, z))
	_house_count += 1


func _build_manantial() -> void:
	var x: float = 55.0
	var z: float = 45.0
	var ground: float = _ground(x, z)
	var basin: MeshInstance3D = _cylinder(4.0, 0.9, Vector3(x, ground + 0.45, z))
	basin.name = "Manantial"
	_cylinder(3.4, 0.15, Vector3(x, ground + 0.92, z), WATER)
	_add_label("POI-03 · Manantial", Vector3(x, ground + 3.0, z))


func _build_acequia() -> void:
	var points: PackedVector3Array = PackedVector3Array(
		[
			Vector3(55.0, 0.0, 45.0),
			Vector3(80.0, 0.0, 65.0),
			Vector3(110.0, 0.0, 85.0),
			Vector3(145.0, 0.0, 105.0),
		]
	)
	var mesh: MeshInstance3D = _ribbon(points, 1.4, WATER, 0.35)
	mesh.name = "Acequia"


func _build_corral() -> void:
	var center: Vector3 = Vector3(-55.0, 0.0, 45.0)
	var ground: float = _ground(center.x, center.z)
	_add_box(
		Vector3(12.0, 1.2, 0.6),
		Vector3(-55.0, ground + 0.6, 39.0),
		STONE,
		true,
		Basis.IDENTITY,
		"Corral"
	)
	_add_box(
		Vector3(12.0, 1.2, 0.6),
		Vector3(-55.0, ground + 0.6, 51.0),
		STONE,
		true,
		Basis.IDENTITY,
		"Corral"
	)
	_add_box(
		Vector3(0.6, 1.2, 12.0),
		Vector3(-61.0, ground + 0.6, 45.0),
		STONE,
		true,
		Basis.IDENTITY,
		"Corral"
	)
	_add_label("POI-05 · Corral de llamas", Vector3(center.x, ground + 3.0, center.z))


func _build_telar() -> void:
	var x: float = 22.0
	var z: float = -28.0
	var ground: float = _ground(x, z)
	for post_x: float in [-1.2, 1.2]:
		for post_z: float in [-0.8, 0.8]:
			_add_box(
				Vector3(0.18, 2.2, 0.18),
				Vector3(x + post_x, ground + 1.1, z + post_z),
				WOOD,
				false,
				Basis.IDENTITY,
				"Telar"
			)
	_add_box(
		Vector3(2.8, 0.18, 0.18),
		Vector3(x, ground + 2.1, z - 0.8),
		WOOD,
		false,
		Basis.IDENTITY,
		"Telar"
	)
	_add_label("POI-04 · Telar comunal", Vector3(x, ground + 3.2, z))


func _build_huerto() -> void:
	var center: Vector3 = Vector3(-20.0, 0.0, -50.0)
	var ground: float = _ground(center.x, center.z)
	for index: int in 4:
		var offset: float = float(index) * 4.0
		_add_box(
			Vector3(5.0, 0.3, 3.0),
			Vector3(center.x, ground + 0.15, center.z - offset),
			SOIL,
			false,
			Basis.IDENTITY,
			"Huerto"
		)
	_add_label("POI-10 · Huerto de papa y quinua", Vector3(center.x, ground + 3.0, center.z))


func _build_horno() -> void:
	var x: float = 35.0
	var z: float = 58.0
	var ground: float = _ground(x, z)
	_cylinder(2.0, 1.4, Vector3(x, ground + 0.7, z), STONE)
	_add_label("POI-07 · Horno de cerámica", Vector3(x, ground + 3.0, z))


func _build_fogon() -> void:
	var x: float = 10.0
	var z: float = 16.0
	var ground: float = _ground(x, z)
	_cylinder(1.4, 0.5, Vector3(x, ground + 0.25, z), ROOF)
	_add_label("POI-08 · Fogón comunal", Vector3(x, ground + 2.5, z))


func _add_box(
	size: Vector3,
	box_position: Vector3,
	color: Color,
	collision: bool,
	orientation: Basis,
	name_hint: String
) -> Node3D:
	return BlockoutKit.add_box(self, size, box_position, color, collision, orientation, name_hint)


func _cylinder(
	radius: float, height: float, mesh_position: Vector3, color: Color = STONE
) -> MeshInstance3D:
	return BlockoutKit.add_cylinder(self, radius, height, mesh_position, color)


func _ribbon(points: PackedVector3Array, width: float, color: Color, lift: float) -> MeshInstance3D:
	return BlockoutKit.add_ribbon(self, points, _ground, width, color, lift)


func _add_label(text: String, label_position: Vector3) -> void:
	_poi_labels.append(BlockoutKit.add_label(self, text, label_position))


func _ground(x: float, z: float) -> float:
	if _region == null:
		return global_position.y
	return _region.height_at(global_position.x + x, global_position.z + z)


func _max_ground(x: float, z: float, size: Vector3) -> float:
	var heights: Array[float] = [
		_ground(x, z),
		_ground(x - size.x * 0.5, z - size.z * 0.5),
		_ground(x + size.x * 0.5, z - size.z * 0.5),
		_ground(x - size.x * 0.5, z + size.z * 0.5),
		_ground(x + size.x * 0.5, z + size.z * 0.5),
	]
	var maximum: float = heights[0]
	for height: float in heights:
		maximum = maxf(maximum, height)
	return maximum
