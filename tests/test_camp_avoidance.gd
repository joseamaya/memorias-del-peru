extends RefCounted
## Comprueba la evitación local de las tiendas y que el layout del campamento
## es el mismo que usan el mirador y la batalla.
##
## La prueba recorre cada hueco de aparición con el mismo paso de física y
## comprueba que un cuerpo llega al centro sin entrar en una tienda. Es la
## garantía que faltaba: el chanca del hueco 1 de la oleada 1 nacía dentro de
## la tienda 4 y la oleada no cerraba.


func test_layout_has_twelve_tents() -> bool:
	return CampLayout.tents(CarmencaBattle.CAMP).size() == CampLayout.COLUMNS * CampLayout.ROWS


func test_layout_keeps_the_known_tent() -> bool:
	# La tienda 4 es la que atrapaba el hueco 1 de la oleada 1: su centro no
	# puede moverse.
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CarmencaBattle.CAMP)
	var tent: CampLayout.Tent = tents[4]
	var expected: Vector3 = CarmencaBattle.CAMP + Vector3(-12.45, 0.0, 0.0)
	return tent.center.is_equal_approx(expected) and is_equal_approx(tent.radius, 2.2)


func test_old_wave_one_slot_was_inside_a_tent() -> bool:
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CarmencaBattle.CAMP)
	var old_point: Vector3 = CarmencaBattle.CAMP + Vector3(-10.4, 0.0, 0.0)
	return not CampAvoidance.is_clear(old_point, tents, CampAvoidance.SPAWN_MARGIN)


func test_steering_breaks_the_radial_deadlock() -> bool:
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CarmencaBattle.CAMP)
	var tent: CampLayout.Tent = tents[2]
	var position: Vector3 = tent.center + Vector3(tent.radius + 0.5, 0.0, 0.0)
	var steer: Vector3 = CampAvoidance.steer(Vector3(-2.4, 0.0, 0.0), position, tents, 0.42, 0)
	return absf(steer.z) > 0.1 and steer.x < 0.0


func test_steering_leaves_a_clear_path_alone() -> bool:
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CarmencaBattle.CAMP)
	var position: Vector3 = CarmencaBattle.CAMP + Vector3(20.0, 0.0, 0.0)
	var desired: Vector3 = Vector3(2.4, 0.0, 0.0)
	return CampAvoidance.steer(desired, position, tents, 0.42, 0).is_equal_approx(desired)


func test_every_wave_slot_reaches_the_camp() -> bool:
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CarmencaBattle.CAMP)
	for count: int in [2, 4, 6, 8]:
		for slot: int in count:
			var start: Vector3 = CarmencaSpawn.offset(
				CarmencaBattle.CAMP, slot, count, CarmencaBattle.CAMP, tents
			)
			if not _reaches_camp(start, tents, slot):
				return false
	return true


## Simula un cuerpo que va al centro a 2,4 m/s, con el paso de 60 Hz.
func _reaches_camp(start: Vector3, tents: Array[CampLayout.Tent], slot: int) -> bool:
	var position: Vector3 = Vector3(start.x, 0.0, start.z)
	for _step: int in 1800:
		if CampAvoidance.flat_distance(position, CarmencaBattle.CAMP) <= 1.6:
			return true
		var desired: Vector3 = CarmencaBattle.CAMP - position
		desired.y = 0.0
		if desired.length_squared() <= 0.0001:
			return true
		desired = desired.normalized() * 2.4
		var steer: Vector3 = CampAvoidance.steer(desired, position, tents, 0.42, slot)
		if steer.length() < 0.05:
			return false
		position += steer * (1.0 / 60.0)
		if CampAvoidance.inside_any(position, tents, 0.1):
			return false
	return false
