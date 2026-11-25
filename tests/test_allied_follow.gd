extends RefCounted
## Comprueba la formación y el paso de los aliados.
##
## El caso que fallaba en la partida: los seis compartían un único punto detrás
## del jugador y, en el borde de los 2,4 m, alternaban entre ceder y volver al
## punto. También se comprueba que cada uno tiene su hueco y que rodea al
## jugador en vez de atravesar su espacio personal.

const FORWARD: Vector3 = Vector3(0.0, 0.0, -1.0)
const PLAYER: Vector3 = Vector3.ZERO
const STEP: float = 1.0 / 60.0


func test_ally_in_front_cedes_sideways() -> bool:
	var velocity: Vector3 = AlliedWarrior.follow_velocity(
		Vector3(0.0, 0.0, -1.2), PLAYER, FORWARD, 0
	)
	var ok: bool = velocity.length() > 0.1
	# Se aparta de la línea de mirada, no empuja al jugador de frente.
	ok = ok and absf(velocity.normalized().dot(FORWARD)) < 0.1
	return ok


func test_ally_too_close_behind_backs_away() -> bool:
	var velocity: Vector3 = AlliedWarrior.follow_velocity(
		Vector3(0.0, 0.0, 1.2), PLAYER, FORWARD, 0
	)
	return velocity.length() > 0.1 and velocity.z > 0.0


func test_ally_waits_at_its_spot() -> bool:
	var spot: Vector3 = AlliedWarrior.slot_position(PLAYER, FORWARD, 1)
	return AlliedWarrior.follow_velocity(spot, PLAYER, FORWARD, 1).is_zero_approx()


func test_ally_returns_behind_from_the_front() -> bool:
	var velocity: Vector3 = AlliedWarrior.follow_velocity(
		Vector3(0.0, 0.0, -8.0), PLAYER, FORWARD, 1
	)
	# El punto de espera está detrás: se mueve hacia +Z, no se queda quieto.
	return velocity.length() > 0.1 and velocity.z > 0.0


func test_allied_slots_are_distinct() -> bool:
	var spots: Array[Vector3] = []
	for slot: int in 6:
		spots.append(AlliedWarrior.slot_position(PLAYER, FORWARD, slot))
	for first: int in spots.size():
		for second: int in range(first + 1, spots.size()):
			if (
				Vector2(spots[first].x - spots[second].x, spots[first].z - spots[second].z).length()
				< 1.1
			):
				return false
	return true


func test_ally_does_not_step_into_personal_space_at_the_edge() -> bool:
	# Justo por fuera del borde: antes el aliado giraba hacia el punto de
	# espera y se metía en el espacio personal; ahora rodea sin acercarse.
	var position: Vector3 = Vector3(0.0, 0.0, -2.41)
	var velocity: Vector3 = AlliedWarrior.follow_velocity(position, PLAYER, FORWARD, 1)
	var radial: Vector3 = position.normalized()
	return velocity.length() > 0.1 and velocity.normalized().dot(radial) >= -0.05


func test_ally_orbits_without_crossing_the_player() -> bool:
	var position: Vector3 = Vector3(0.0, 0.0, -2.35)
	var spot: Vector3 = AlliedWarrior.slot_position(PLAYER, FORWARD, 1)
	for _step: int in 900:
		var velocity: Vector3 = AlliedWarrior.follow_velocity(position, PLAYER, FORWARD, 1)
		if velocity.length() < 0.001:
			break
		position += velocity * STEP
		var flat: Vector3 = Vector3(position.x, 0.0, position.z)
		if flat.length() < AlliedWarrior.PERSONAL_SPACE - 0.1:
			return false
	return Vector2(position.x - spot.x, position.z - spot.z).length() <= 0.45
