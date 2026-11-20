class_name CuscoBlockout
extends Node3D
## Blockout de S1 — Cusco preimperial.
##
## Plaza, recinto del Coricancha, ayllus, mercado, talleres, depósitos y
## acequia urbana. Geometría gris de blockout, no arte ni reconstrucción.

const PLAZA_RADIUS: float = 28.0
const HOUSE_SIZE: Vector3 = Vector3(5.5, 2.5, 4.0)
const HOUSE_X: Array[float] = [-135.0, -105.0, -75.0, -45.0, 45.0, 75.0, 105.0, 135.0]
const HOUSE_Z: Array[float] = [-105.0, -75.0, -45.0, 45.0, 75.0, 105.0]

const STONE: Color = Color(0.66, 0.62, 0.54)
const WALL: Color = Color(0.76, 0.70, 0.58)
const ROOF: Color = Color(0.42, 0.34, 0.25)
const GOLD: Color = Color(0.72, 0.58, 0.30)
const SOIL: Color = Color(0.38, 0.30, 0.20)
const WATER: Color = Color(0.30, 0.48, 0.58)
const WOOD: Color = Color(0.36, 0.28, 0.20)

var _region: CampaignRegion = null
var _poi_labels: Array[Label3D] = []
var _house_count: int = 0


func _ready() -> void:
	_region = get_tree().get_first_node_in_group(&"campaign_region") as CampaignRegion
	if _region == null:
		push_error("CuscoBlockout: falta el terreno regional.")
		return
	_build_plaza()
	_build_houses()
	_build_coricancha()
	_build_market()
	_build_workshop()
	_build_deposits()
	_build_acequia()


func get_house_count() -> int:
	return _house_count


func get_poi_count() -> int:
	return _poi_labels.size()


func get_mesh_count() -> int:
	return find_children("*", "MeshInstance3D", true, false).size()


func get_collision_count() -> int:
	return find_children("*", "StaticBody3D", true, false).size()


func _build_plaza() -> void:
	BlockoutKit.add_terrain_disk(
		self, PLAZA_RADIUS, 0.15, STONE, _ground, 96, 12, Vector2.ZERO, "PlazaCusco"
	)
	_add_label("POI-17 · Plaza del Cusco", Vector3(0.0, _ground(0.0, 0.0) + 3.5, 0.0))


func _build_houses() -> void:
	for x: float in HOUSE_X:
		for z: float in HOUSE_Z:
			if _skip_house(x, z):
				continue
			_house(x, z, HOUSE_SIZE)
	_add_label("POI-21 · Casa de un ayllu", Vector3(75.0, _ground(75.0, 75.0) + 4.0, 75.0))


func _house(x: float, z: float, size: Vector3) -> void:
	var ground: float = _max_ground(x, z, size)
	var low: float = BlockoutKit.min_ground(
		_ground, x, z, Vector3(size.x + 0.4, 0.0, size.z + 0.4)
	)
	var base_height: float = maxf(ground - low + 0.3, 0.5)
	BlockoutKit.add_box(
		self,
		Vector3(size.x + 0.4, base_height, size.z + 0.4),
		Vector3(x, ground - base_height * 0.5 + 0.15, z),
		STONE,
		false,
		Basis.IDENTITY,
		"Foundation"
	)
	BlockoutKit.add_box(
		self, size, Vector3(x, ground + size.y * 0.5, z), WALL, true, Basis.IDENTITY, "Casa"
	)
	BlockoutKit.add_box(
		self,
		Vector3(size.x + 0.8, 0.35, size.z + 0.7),
		Vector3(x, ground + size.y + 0.175, z),
		ROOF,
		false,
		Basis.IDENTITY,
		"Techo"
	)
	_house_count += 1


func _build_coricancha() -> void:
	var center: Vector3 = Vector3(0.0, 0.0, -70.0)
	# La plataforma se apoya en la cota más alta de su huella: con la altura
	# del centro, la ladera la enterraba por un lado y el recinto parecía
	# hundido. La caja se extiende hacia abajo hasta el terreno.
	var ground: float = _max_ground(center.x, center.z, Vector3(38.0, 0.0, 30.0)) + 0.2
	BlockoutKit.add_box(
		self,
		Vector3(38.0, 0.6, 30.0),
		Vector3(center.x, ground + 0.3, center.z),
		GOLD,
		false,
		Basis.IDENTITY,
		"CoricanchaPlataforma"
	)
	BlockoutKit.add_box(
		self,
		Vector3(34.0, 1.6, 0.8),
		Vector3(center.x, ground + 1.4, center.z - 14.0),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		self,
		Vector3(34.0, 1.6, 0.8),
		Vector3(center.x, ground + 1.4, center.z + 14.0),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		self,
		Vector3(0.8, 1.6, 30.0),
		Vector3(center.x - 17.0, ground + 1.4, center.z),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		self,
		Vector3(0.8, 1.6, 30.0),
		Vector3(center.x + 17.0, ground + 1.4, center.z),
		STONE,
		true,
		Basis.IDENTITY,
		"CoricanchaMuro"
	)
	BlockoutKit.add_box(
		self,
		Vector3(12.0, 2.6, 8.0),
		Vector3(center.x, ground + 1.3, center.z),
		GOLD,
		true,
		Basis.IDENTITY,
		"CoricanchaRecinto"
	)
	_add_label("POI-18 · Coricancha", Vector3(center.x, ground + 6.0, center.z))


func _build_market() -> void:
	var spots: Array[Vector2] = [
		Vector2(-70.0, 50.0),
		Vector2(-60.0, 60.0),
		Vector2(-80.0, 60.0),
		Vector2(-70.0, 70.0),
		Vector2(-55.0, 70.0),
		Vector2(-85.0, 70.0),
	]
	for spot: Vector2 in spots:
		var ground: float = _ground(spot.x, spot.y)
		BlockoutKit.add_box(
			self,
			Vector3(3.0, 2.0, 2.0),
			Vector3(spot.x, ground + 1.0, spot.y),
			WOOD,
			true,
			Basis.IDENTITY,
			"Puesto"
		)
		BlockoutKit.add_box(
			self,
			Vector3(3.6, 0.3, 2.6),
			Vector3(spot.x, ground + 2.15, spot.y),
			ROOF,
			false,
			Basis.IDENTITY,
			"Toldo"
		)
	_add_label("POI-19 · Mercado", Vector3(-70.0, _ground(-70.0, 60.0) + 5.0, 60.0))


func _build_workshop() -> void:
	_house(60.0, -55.0, HOUSE_SIZE)
	_house(75.0, -55.0, HOUSE_SIZE)
	var ground: float = _ground(67.0, -40.0)
	for index: int in 3:
		var x: float = 60.0 + float(index) * 5.0
		var post_ground: float = _ground(x, -40.0)
		BlockoutKit.add_box(
			self,
			Vector3(0.18, 2.0, 0.18),
			Vector3(x, post_ground + 1.0, -40.0),
			WOOD,
			false,
			Basis.IDENTITY,
			"Telar"
		)
	_add_label("POI-20 · Taller textil", Vector3(67.0, ground + 4.0, -40.0))


func _build_deposits() -> void:
	for index: int in 4:
		var z: float = -105.0 + float(index) * 10.0
		var ground: float = _ground(115.0, z)
		BlockoutKit.add_box(
			self,
			Vector3(12.0, 1.5, 4.0),
			Vector3(115.0, ground + 0.75, z),
			STONE,
			true,
			Basis.IDENTITY,
			"Deposito"
		)
	_add_label("POI-22 · Depósito del Cusco", Vector3(115.0, _ground(115.0, -80.0) + 4.0, -80.0))


func _build_acequia() -> void:
	var points: PackedVector3Array = PackedVector3Array(
		[
			Vector3(-140.0, 0.0, 35.0),
			Vector3(-80.0, 0.0, 42.0),
			Vector3(0.0, 0.0, 45.0),
			Vector3(80.0, 0.0, 42.0),
			Vector3(140.0, 0.0, 35.0),
		]
	)
	var mesh: MeshInstance3D = BlockoutKit.add_ribbon(self, points, _ground, 1.4, WATER, 0.12)
	mesh.name = "AcequiaUrbana"


func _skip_house(x: float, z: float) -> bool:
	if Vector2(x, z).length() < 42.0:
		return true
	if x < -35.0 and z < 0.0:
		return true
	if x > -95.0 and x < -40.0 and z > 40.0 and z < 85.0:
		return true
	if x > 40.0 and x < 85.0 and z < -30.0 and z > -70.0:
		return true
	if x > 85.0 and z < -60.0:
		return true
	return false


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
