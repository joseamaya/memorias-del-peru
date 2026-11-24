extends RefCounted
## Comprueba el anillo de aparición de Carmenca: ningún chanca nace sobre el
## jugador y el hueco que cae dentro se refleja al otro lado del campamento.
##
## Antes esta rama no se ejecutaba en ninguna prueba: con el jugador a 20 m y
## un radio máximo de 13 m, la distancia mínima era 7 m y la condición nunca se
## cumplía.


func test_inside_camp_keeps_every_slot_away() -> bool:
	var player: Vector3 = CarmencaBattle.CAMP + Vector3(5.0, 0.0, 0.0)
	var ok: bool = true
	for count: int in [2, 4, 6, 8]:
		for slot: int in count:
			var point: Vector3 = _slot(slot, count, player)
			ok = ok and _flat_distance(point, player) >= CarmencaSpawn.MIN_DISTANCE
	return ok


func test_slot_over_player_is_reflected() -> bool:
	var count: int = 4
	var rim: Vector3 = _slot(0, count, CarmencaBattle.CAMP)
	var player: Vector3 = Vector3(rim.x, 0.0, rim.z)
	var point: Vector3 = _slot(0, count, player)
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


func _slot(slot: int, count: int, player: Vector3) -> Vector3:
	return CarmencaSpawn.offset(CarmencaBattle.CAMP, slot, count, player)


func _flat_distance(a: Vector3, b: Vector3) -> float:
	return Vector2(a.x - b.x, a.z - b.z).length()
