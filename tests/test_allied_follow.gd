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
const CAMP: Vector3 = CarmencaBattle.CAMP


func test_ally_in_front_cedes_sideways() -> bool:
	var velocity: Vector3 = AlliedFormation.follow_velocity(
		Vector3(0.0, 0.0, -1.2), PLAYER, FORWARD, 0
	)
	var ok: bool = velocity.length() > 0.1
	# Se aparta de la línea de mirada, no empuja al jugador de frente.
	ok = ok and absf(velocity.normalized().dot(FORWARD)) < 0.1
	return ok


func test_ally_too_close_behind_backs_away() -> bool:
	var velocity: Vector3 = AlliedFormation.follow_velocity(
		Vector3(0.0, 0.0, 1.2), PLAYER, FORWARD, 0
	)
	return velocity.length() > 0.1 and velocity.z > 0.0


func test_ally_waits_at_its_spot() -> bool:
	var spot: Vector3 = AlliedFormation.slot_position(PLAYER, FORWARD, 1)
	return AlliedFormation.follow_velocity(spot, PLAYER, FORWARD, 1).is_zero_approx()


func test_ally_returns_behind_from_the_front() -> bool:
	var velocity: Vector3 = AlliedFormation.follow_velocity(
		Vector3(0.0, 0.0, -8.0), PLAYER, FORWARD, 1
	)
	# El punto de espera está detrás: se mueve hacia +Z, no se queda quieto.
	return velocity.length() > 0.1 and velocity.z > 0.0


func test_allied_slots_are_distinct() -> bool:
	var spots: Array[Vector3] = []
	for slot: int in 6:
		spots.append(AlliedFormation.slot_position(PLAYER, FORWARD, slot))
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
	var velocity: Vector3 = AlliedFormation.follow_velocity(position, PLAYER, FORWARD, 1)
	var radial: Vector3 = position.normalized()
	return velocity.length() > 0.1 and velocity.normalized().dot(radial) >= -0.05


func test_ally_orbits_without_crossing_the_player() -> bool:
	var position: Vector3 = Vector3(0.0, 0.0, -2.35)
	var spot: Vector3 = AlliedFormation.slot_position(PLAYER, FORWARD, 1)
	for _step: int in 900:
		var velocity: Vector3 = AlliedFormation.follow_velocity(position, PLAYER, FORWARD, 1)
		if velocity.length() < 0.001:
			break
		position += velocity * STEP
		var flat: Vector3 = Vector3(position.x, 0.0, position.z)
		if flat.length() < AlliedFormation.PERSONAL_SPACE - 0.1:
			return false
	return Vector2(position.x - spot.x, position.z - spot.z).length() <= 0.45


func test_follow_spots_near_a_tent_are_clear_and_spaced() -> bool:
	# El caso del fallo: el jugador está 4 m delante de una tienda y la tienda
	# le queda a la espalda, justo donde caen los seis puestos de formación.
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CAMP)
	var tent: CampLayout.Tent = tents[7]
	var player: Vector3 = tent.center + Vector3(-4.0, 0.0, 0.0)
	var forward: Vector3 = Vector3(-1.0, 0.0, 0.0)
	var spots: Array[Vector3] = AlliedFormation.follow_spots(player, forward, tents)
	if spots.size() != AlliedFormation.SLOT_COUNT:
		return false
	for spot: Vector3 in spots:
		if not CampAvoidance.is_clear(spot, tents, AlliedWarrior.BODY_RADIUS):
			return false
		if _flat_distance(spot, player) > 12.0:
			return false
	return _min_gap(spots) >= AlliedFormation.SPOT_GAP - 0.05


func test_open_formation_keeps_the_base_spots() -> bool:
	var spots: Array[Vector3] = AlliedFormation.follow_spots(PLAYER, FORWARD, [])
	for slot: int in spots.size():
		var base: Vector3 = AlliedFormation.slot_position(PLAYER, FORWARD, slot)
		if _flat_distance(spots[slot], base) > 0.01:
			return false
	return true


func test_following_allies_settle_clear_of_the_tent() -> bool:
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CAMP)
	var tent: CampLayout.Tent = tents[7]
	var player: Vector3 = tent.center + Vector3(-4.0, 0.0, 0.0)
	var forward: Vector3 = Vector3(-1.0, 0.0, 0.0)
	var positions: Array[Vector3] = []
	var left_tent: Array[bool] = []
	for slot: int in AlliedFormation.SLOT_COUNT:
		positions.append(AlliedFormation.slot_position(player, forward, slot))
		left_tent.append(false)
	for _step: int in 900:
		if not _advance_allies(positions, player, forward, tents, left_tent):
			return false
	var before: Array[Vector3] = positions.duplicate()
	for _step: int in 30:
		if not _advance_allies(positions, player, forward, tents, left_tent):
			return false
	for slot: int in positions.size():
		if not left_tent[slot]:
			return false
		if not CampAvoidance.is_clear(positions[slot], tents, AlliedWarrior.BODY_RADIUS):
			return false
		if _flat_distance(before[slot], positions[slot]) > 0.05:
			return false
	return _min_gap(positions) >= AlliedFormation.ALLY_GAP - 0.05


func test_ally_inside_a_tent_and_close_to_the_player_leaves_it() -> bool:
	# El caso que se veía en la batalla: el aliado acaba dentro de la tienda y a
	# menos de 2,4 m del jugador. La órbita del espacio personal lo empujaba
	# hacia fuera de la tienda y lo dejaba clavado en el borde.
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CAMP)
	var tent: CampLayout.Tent = tents[7]
	var player: Vector3 = tent.center + Vector3(-4.0, 0.0, 0.0)
	var forward: Vector3 = Vector3(-1.0, 0.0, 0.0)
	var position: Vector3 = tent.center + Vector3(-2.0, 0.0, 0.0)
	if not CampAvoidance.inside_any(position, tents, 0.0):
		return false
	var left: bool = false
	for _step: int in 600:
		var velocity: Vector3 = AlliedFormation.follow_velocity(position, player, forward, 1, tents)
		velocity = CampAvoidance.steer(velocity, position, tents, AlliedWarrior.BODY_RADIUS, 1)
		position += velocity * STEP
		if not CampAvoidance.inside_any(position, tents, 0.0):
			left = true
		elif left:
			return false
	return left and CampAvoidance.is_clear(position, tents, 0.0)


func test_ally_at_the_tent_edge_does_not_oscillate() -> bool:
	# Justo fuera de la huella y dentro del espacio personal: el empuje radial
	# apuntaba a la tienda y el aliado entraba y salía sin parar.
	var tents: Array[CampLayout.Tent] = CampLayout.tents(CAMP)
	var tent: CampLayout.Tent = tents[7]
	var player: Vector3 = tent.center + Vector3(-4.0, 0.0, 0.0)
	var forward: Vector3 = Vector3(-1.0, 0.0, 0.0)
	var position: Vector3 = tent.center + Vector3(-2.75, 0.0, 0.0)
	if CampAvoidance.inside_any(position, tents, 0.0):
		return false
	for _step: int in 600:
		var velocity: Vector3 = AlliedFormation.follow_velocity(position, player, forward, 1, tents)
		velocity = CampAvoidance.steer(velocity, position, tents, AlliedWarrior.BODY_RADIUS, 1)
		position += velocity * STEP
		if CampAvoidance.inside_any(position, tents, 0.0):
			return false
	var before: Vector3 = position
	for _step: int in 30:
		var velocity: Vector3 = AlliedFormation.follow_velocity(position, player, forward, 1, tents)
		velocity = CampAvoidance.steer(velocity, position, tents, AlliedWarrior.BODY_RADIUS, 1)
		position += velocity * STEP
	return _left_still(before, position)


func _left_still(before: Vector3, after: Vector3) -> bool:
	return _flat_distance(before, after) <= 0.05


func test_separation_pushes_overlapping_allies_apart() -> bool:
	var others: Array[Vector3] = [Vector3(0.1, 0.0, 0.0)]
	var velocity: Vector3 = AlliedFormation.separate_velocity(
		Vector3(2.7, 0.0, 0.0), Vector3.ZERO, others, 0
	)
	return velocity.x < 0.0


func test_separation_keeps_allies_that_are_far_apart() -> bool:
	var others: Array[Vector3] = [Vector3(2.0, 0.0, 0.0)]
	var velocity: Vector3 = AlliedFormation.separate_velocity(
		Vector3(2.7, 0.0, 0.0), Vector3.ZERO, others, 0
	)
	return velocity.is_equal_approx(Vector3(2.7, 0.0, 0.0))


func test_separation_breaks_a_zero_distance_overlap() -> bool:
	var first: Array[Vector3] = [Vector3.ZERO]
	var second: Array[Vector3] = [Vector3.ZERO]
	var velocity_a: Vector3 = AlliedFormation.separate_velocity(
		Vector3.ZERO, Vector3.ZERO, first, 0
	)
	var velocity_b: Vector3 = AlliedFormation.separate_velocity(
		Vector3.ZERO, Vector3.ZERO, second, 3
	)
	return (
		velocity_a.length() > 0.1 and velocity_b.length() > 0.1 and velocity_a.dot(velocity_b) < 0.0
	)


func _advance_allies(
	positions: Array[Vector3],
	player: Vector3,
	forward: Vector3,
	tents: Array[CampLayout.Tent],
	left_tent: Array[bool],
) -> bool:
	for slot: int in positions.size():
		var velocity: Vector3 = AlliedFormation.follow_velocity(
			positions[slot], player, forward, slot, tents
		)
		velocity = CampAvoidance.steer(
			velocity, positions[slot], tents, AlliedWarrior.BODY_RADIUS, slot
		)
		positions[slot] += velocity * STEP
		if not CampAvoidance.inside_any(positions[slot], tents, 0.0):
			left_tent[slot] = true
		elif left_tent[slot]:
			return false
	return true


func _min_gap(positions: Array[Vector3]) -> float:
	var gap: float = INF
	for first: int in positions.size():
		for second: int in range(first + 1, positions.size()):
			gap = minf(gap, _flat_distance(positions[first], positions[second]))
	return gap


func _flat_distance(first: Vector3, second: Vector3) -> float:
	return Vector2(first.x - second.x, first.z - second.z).length()
