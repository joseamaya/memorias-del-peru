extends RefCounted
## Comprueba el anillo de aparición de Carmenca: ningún chanca nace sobre el
## jugador, sobre una tienda o dentro de una. El hueco que cae sobre el jugador
## se refleja al otro lado del campamento.
##
## Antes la rama del reflejo no se ejecutaba en ninguna prueba: con el jugador a
## 20 m y un radio máximo de 13 m, la distancia mínima era 7 m y la condición
## nunca se cumplía. Después, el hueco 1 de la oleada 1 caía dentro de la tienda
## 4 y dejaba la oleada sin cerrar.


func test_inside_camp_keeps_every_slot_away() -> bool:
	var player: Vector3 = CarmencaBattle.CAMP + Vector3(5.0, 0.0, 0.0)
	var ok: bool = true
	for count: int in [2, 4, 6, 8]:
		for slot: int in count:
			var point: Vector3 = _slot(slot, count, player, _tents())
			ok = ok and _flat_distance(point, player) >= CarmencaSpawn.MIN_DISTANCE
	return ok


func test_slot_over_player_is_reflected() -> bool:
	var count: int = 4
	var rim: Vector3 = _slot(0, count, CarmencaBattle.CAMP)
	var player: Vector3 = Vector3(rim.x, 0.0, rim.z)
	var point: Vector3 = _slot(0, count, player, _tents())
	var ok: bool = _flat_distance(point, player) >= CarmencaSpawn.MIN_DISTANCE
	# No se queda en el mismo punto: el hueco pasa al lado opuesto.
	ok = ok and _flat_distance(point, rim) > CarmencaSpawn.MIN_DISTANCE
	return ok


func test_player_outside_ring_keeps_slots() -> bool:
	var far: Vector3 = CarmencaBattle.CAMP + Vector3(20.0, 0.0, 0.0)
	var ok: bool = true
	for slot: int in 6:
		var base: Vector3 = _slot(slot, 6, CarmencaBattle.CAMP)
		var point: Vector3 = _slot(slot, 6, far)
		ok = ok and point.is_equal_approx(base)
	return ok


func test_wave_slots_are_clear_of_tents() -> bool:
	var tents: Array[CampLayout.Tent] = _tents()
	var ok: bool = true
	for count: int in [2, 4, 6, 8]:
		for slot: int in count:
			var point: Vector3 = _slot(slot, count, CarmencaBattle.CAMP, tents)
			ok = ok and CampAvoidance.is_clear(point, tents, CarmencaSpawn.CLEARANCE)
	return ok


func test_wave_one_slot_was_inside_a_tent() -> bool:
	# El caso que atascaba la oleada 1: (776,6, 307) caía a 2,05 m del centro
	# de la tienda 4, de 2,2 m de radio.
	var tents: Array[CampLayout.Tent] = _tents()
	var point: Vector3 = _slot(1, 2, CarmencaBattle.CAMP, tents)
	return CampAvoidance.is_clear(point, tents, CarmencaSpawn.CLEARANCE)


func test_ally_clear_near_leaves_tents() -> bool:
	var tents: Array[CampLayout.Tent] = _tents()
	var player: Vector3 = CarmencaBattle.CAMP
	var ok: bool = true
	for angle_index: int in 8:
		var angle: float = TAU * float(angle_index) / 8.0
		var preferred: Vector3 = player + Vector3(cos(angle), 0.0, sin(angle)) * 4.5
		var point: Vector3 = CarmencaSpawn.clear_near(player, preferred, tents)
		ok = ok and CampAvoidance.is_clear(point, tents, CarmencaSpawn.CLEARANCE)
	return ok


func test_fallback_never_returns_a_point_inside_a_tent() -> bool:
	# Una tienda sintética de 30 m cubre todos los candidatos normales y el
	# respaldo antiguo a 24 m. El respaldo nuevo tiene que salir de su huella.
	var tents: Array[CampLayout.Tent] = []
	tents.append(CampLayout.Tent.new(Vector3.ZERO, 30.0, 3.0, false))
	var point: Vector3 = CarmencaSpawn.clear_near(Vector3.ZERO, Vector3(1.0, 0.0, 0.0), tents)
	return CampAvoidance.is_clear(point, tents, 0.0)


func _tents() -> Array[CampLayout.Tent]:
	return CampLayout.tents(CarmencaBattle.CAMP)


func _slot(slot: int, count: int, player: Vector3, tents: Array[CampLayout.Tent] = []) -> Vector3:
	return CarmencaSpawn.offset(CarmencaBattle.CAMP, slot, count, player, tents)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
