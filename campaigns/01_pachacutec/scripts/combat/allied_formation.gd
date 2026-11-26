class_name AlliedFormation
extends RefCounted
## Formación, seguimiento y separación de los aliados de Carmenca.
##
## Vive fuera de [AlliedWarrior] para que la lógica de movimiento no engorde al
## cuerpo y para poder probarla sin instanciar la escena. No usa navmesh: los
## puestos se resuelven contra las huellas de las tiendas y el cuerpo se apoya en
## [CampAvoidance] para rodearlas.

const SPEED: float = 2.7
## Punto de espera detrás del jugador, no delante de su mirada.
const FOLLOW_DISTANCE: float = 3.6
## Formación de espera: tres columnas por dos filas detrás del jugador.
const SLOT_COLUMNS: int = 3
const SLOT_ROWS: int = 2
const SLOT_COUNT: int = SLOT_COLUMNS * SLOT_ROWS
const SLOT_LATERAL: float = 1.5
const SLOT_DEPTH: float = 1.2
## Si el jugador se le echa encima, el aliado cede el paso en vez de bloquearlo.
const PERSONAL_SPACE: float = 2.4
const YIELD_SPEED: float = 3.2
## Separación mínima entre dos aliados y empuje para recuperarla.
const ALLY_GAP: float = 1.1
const SEPARATION_PUSH: float = 1.0
## Radio en el que se empieza a rodear a un compañero para no bloquear su puesto.
const ALLY_AVOID: float = 1.3
const TANGENT_PUSH: float = 0.8
## Margen libre alrededor de una tienda para un puesto de espera.
const SPOT_MARGIN: float = 0.5
## Separación mínima entre dos puestos de la formación resuelta.
const SPOT_GAP: float = 1.45
## Los huecos base se aceptan con la separación original (1,2 m entre filas).
const SPOT_BASE_GAP: float = 1.1
## Búsqueda de un puesto libre: 5° por paso, hasta media vuelta.
const SPOT_ANGLE_STEP: float = PI / 36.0
const SPOT_MAX_ANGLE: float = PI
const SPOT_SCALE_STEP: float = 0.15
const SPOT_MAX_SCALE: float = 10.0


## Punto de espera de un aliado según su hueco de formación.
static func slot_position(player_position: Vector3, player_forward: Vector3, slot: int) -> Vector3:
	var forward: Vector3 = Vector3(player_forward.x, 0.0, player_forward.z)
	forward = forward.normalized() if forward.length_squared() > 0.001 else Vector3.FORWARD
	var side: Vector3 = Vector3(-forward.z, 0.0, forward.x)
	var row: int = floori(float(slot) / float(SLOT_COLUMNS))
	var column: int = slot % SLOT_COLUMNS
	var lateral: float = float(column - 1) * SLOT_LATERAL
	var depth: float = FOLLOW_DISTANCE + float(row) * SLOT_DEPTH
	return player_position - forward * depth + side * lateral


## Los seis puestos de espera, libres de tiendas y separados entre sí.
##
## Se calculan en orden de hueco y en el mismo orden para todos los aliados:
## así los seis acuerdan la misma formación y no se pelean por el mismo punto.
## Si una tienda ocupa un puesto, se gira alrededor del jugador conservando el
## radio y, si hace falta, se aleja. Nunca se devuelve un punto dentro de una
## tienda.
static func follow_spots(
	player_position: Vector3,
	player_forward: Vector3,
	tents: Array[CampLayout.Tent] = [],
) -> Array[Vector3]:
	var spots: Array[Vector3] = []
	for index: int in SLOT_COUNT:
		var base: Vector3 = slot_position(player_position, player_forward, index)
		spots.append(_clear_spot(player_position, base, tents, spots))
	return spots


## Puesto de espera resultante para un hueco concreto.
static func follow_spot(
	player_position: Vector3,
	player_forward: Vector3,
	slot: int,
	tents: Array[CampLayout.Tent] = [],
) -> Vector3:
	var spots: Array[Vector3] = follow_spots(player_position, player_forward, tents)
	return spots[clampi(slot, 0, spots.size() - 1)]


## Busca el primer punto libre y separado de los puestos ya elegidos.
static func _clear_spot(
	player_position: Vector3,
	base: Vector3,
	tents: Array[CampLayout.Tent],
	used: Array[Vector3],
) -> Vector3:
	if _spot_is_free(base, tents, used, SPOT_BASE_GAP):
		return base
	var flat: Vector3 = Vector3(base.x - player_position.x, 0.0, base.z - player_position.z)
	var radius: float = flat.length()
	if radius < 0.1:
		return base
	var angle: float = atan2(flat.z, flat.x)
	var factor: float = 1.0
	while factor <= SPOT_MAX_SCALE:
		var distance: float = radius * factor
		var step: int = 0
		while float(step) * SPOT_ANGLE_STEP <= SPOT_MAX_ANGLE:
			var offset: float = float(step) * SPOT_ANGLE_STEP
			var candidate: Vector3 = _spot_at(player_position, angle + offset, distance)
			if _spot_is_free(candidate, tents, used):
				return candidate
			if step > 0:
				candidate = _spot_at(player_position, angle - offset, distance)
				if _spot_is_free(candidate, tents, used):
					return candidate
			step += 1
		factor += SPOT_SCALE_STEP
	return _fallback_spot(player_position, angle, radius, tents, used)


## Punto a `radius` del jugador en el ángulo dado.
static func _spot_at(player_position: Vector3, angle: float, radius: float) -> Vector3:
	return player_position + Vector3(cos(angle) * radius, 0.0, sin(angle) * radius)


## ¿El puesto está fuera de las tiendas y lejos de los ya elegidos?
static func _spot_is_free(
	spot: Vector3, tents: Array[CampLayout.Tent], used: Array[Vector3], gap: float = SPOT_GAP
) -> bool:
	if not CampAvoidance.is_clear(spot, tents, SPOT_MARGIN):
		return false
	for other: Vector3 in used:
		if CampAvoidance.flat_distance(spot, other) < gap:
			return false
	return true


## Último recurso: un radio mayor que la huella más lejana deja el punto fuera
## de todas las tiendas por construcción. Solo se llega aquí si el jugador está
## rodeado de tiendas y la búsqueda normal no encontró un hueco.
static func _fallback_spot(
	player_position: Vector3,
	angle: float,
	radius: float,
	tents: Array[CampLayout.Tent],
	used: Array[Vector3],
) -> Vector3:
	var clear_radius: float = radius
	for tent: CampLayout.Tent in tents:
		clear_radius = maxf(
			clear_radius,
			(
				CampAvoidance.flat_distance(player_position, tent.center)
				+ tent.radius
				+ SPOT_MARGIN
				+ 0.5
			)
		)
	var step: int = 0
	while float(step) * SPOT_ANGLE_STEP <= SPOT_MAX_ANGLE:
		var offset: float = float(step) * SPOT_ANGLE_STEP
		var candidate: Vector3 = _spot_at(player_position, angle + offset, clear_radius)
		if _spot_is_free(candidate, tents, used):
			return candidate
		if step > 0:
			candidate = _spot_at(player_position, angle - offset, clear_radius)
			if _spot_is_free(candidate, tents, used):
				return candidate
		step += 1
	return _spot_at(player_position, angle, clear_radius + float(used.size()) * SPOT_GAP)


## Velocidad horizontal del aliado al seguir al jugador, sin estado.
##
## Espera en su hueco de formación y, si el jugador lo tiene encima o el camino
## al hueco cruza su espacio personal, lo rodea en vez de atravesarlo. Antes
## todos compartían un único punto y, en el borde de los 2,4 m, alternaban entre
## ceder y volver al punto: temblaban sin avanzar. Con tiendas, el hueco se
## resuelve contra sus huellas para no perseguir un punto inalcanzable.
static func follow_velocity(
	ally_position: Vector3,
	player_position: Vector3,
	player_forward: Vector3,
	slot: int = 0,
	tents: Array[CampLayout.Tent] = [],
) -> Vector3:
	var forward: Vector3 = Vector3(player_forward.x, 0.0, player_forward.z)
	forward = forward.normalized() if forward.length_squared() > 0.001 else Vector3.FORWARD
	var spot: Vector3 = follow_spot(player_position, forward, slot, tents)
	var to_ally: Vector3 = Vector3(
		ally_position.x - player_position.x, 0.0, ally_position.z - player_position.z
	)
	var to_spot: Vector3 = Vector3(spot.x - ally_position.x, 0.0, spot.z - ally_position.z)
	var distance: float = to_ally.length()
	var spot_radius: float = (
		Vector2(spot.x - player_position.x, spot.z - player_position.z).length()
	)
	if CampAvoidance.inside_any(ally_position, tents, 0.0):
		# Ya está dentro de una tienda: primero sale hacia su puesto. La órbita
		# del espacio personal empujaría hacia fuera de la tienda y lo dejaría
		# clavado en el borde.
		return to_spot.normalized() * SPEED if to_spot.length_squared() > 0.0001 else Vector3.ZERO
	if (
		distance < PERSONAL_SPACE
		or _crosses_personal_space(ally_position, spot, player_position, PERSONAL_SPACE + 0.25)
	):
		return _orbit_velocity(player_position, to_ally, to_spot, forward, spot_radius, slot, tents)
	if to_spot.length() <= 0.4:
		return Vector3.ZERO
	return to_spot.normalized() * SPEED


## ¿El segmento aliado → hueco pasa demasiado cerca del jugador?
static func _crosses_personal_space(
	ally_position: Vector3, spot: Vector3, player_position: Vector3, radius: float
) -> bool:
	var from: Vector2 = Vector2(ally_position.x, ally_position.z)
	var to: Vector2 = Vector2(spot.x, spot.z)
	var center: Vector2 = Vector2(player_position.x, player_position.z)
	var segment: Vector2 = to - from
	var length_squared: float = segment.length_squared()
	var t: float = 0.0
	if length_squared > 0.0001:
		t = clampf((center - from).dot(segment) / length_squared, 0.0, 1.0)
	var closest: Vector2 = from + segment * t
	if t <= 0.001 and to.distance_to(center) >= from.distance_to(center):
		# El camino solo se aleja del jugador: no hay nada que rodear.
		return false
	if t >= 0.999 and from.distance_to(center) >= to.distance_to(center):
		return false
	return closest.distance_to(center) < radius


## Rodea al jugador manteniendo la distancia mientras llega a su hueco.
##
## El empuje hacia fuera se suprime si el punto de salida cae dentro de una
## tienda: entonces solo queda la componente tangencial, que rodea hasta que
## el lado libre permite volver al puesto. Sin esto, el aliado se quedaba
## clavado en el borde de la tienda, empujando hacia dentro.
static func _orbit_velocity(
	player_position: Vector3,
	to_ally: Vector3,
	to_spot: Vector3,
	forward: Vector3,
	spot_radius: float,
	slot: int,
	tents: Array[CampLayout.Tent],
) -> Vector3:
	var distance: float = to_ally.length()
	var radial: Vector3 = to_ally.normalized() if distance > 0.01 else -forward
	var tangent: Vector3 = Vector3(-radial.z, 0.0, radial.x)
	var toward_spot: Vector3 = (
		to_spot.normalized() if to_spot.length_squared() > 0.0001 else -radial
	)
	if absf(tangent.dot(toward_spot)) < 0.05:
		tangent = tangent if slot % 2 == 0 else -tangent
	elif tangent.dot(toward_spot) < 0.0:
		tangent = -tangent
	var radial_speed: float = 0.0
	if distance < PERSONAL_SPACE and radial.dot(forward) < 0.2:
		# Detrás o al lado: se aparta hacia fuera. Delante solo cede de lado,
		# para no retroceder por la línea de mirada del jugador. Si la salida
		# cae en una tienda, primero rodea.
		var yield_point: Vector3 = player_position + radial * (PERSONAL_SPACE + 0.25)
		if not CampAvoidance.inside_any(yield_point, tents, 0.0):
			radial_speed = YIELD_SPEED
	elif distance > spot_radius + 0.6:
		radial_speed = -minf((distance - spot_radius) * 1.5, SPEED)
	return (tangent * SPEED + radial * radial_speed).limit_length(SPEED)


## Evita que dos aliados ocupen el mismo punto durante el combate.
##
## Cancela la componente que acerca a otro aliado, añade un empuje radial y
## rodea al compañero para no quedarse clavado detrás de él. Sin esto, todos van
## al chanca más cercano y se solapan: `move_and_slide` no ve la capa de los
## aliados.
static func separate_velocity(
	desired: Vector3, origin: Vector3, others: Array[Vector3], slot: int
) -> Vector3:
	var result: Vector3 = Vector3(desired.x, 0.0, desired.z)
	var radial_push: Vector3 = Vector3.ZERO
	var tangent_push: Vector3 = Vector3.ZERO
	for other: Vector3 in others:
		var away: Vector3 = origin - other
		away.y = 0.0
		var distance: float = away.length()
		if distance >= ALLY_AVOID:
			continue
		var direction: Vector3
		if distance > 0.001:
			direction = away / distance
		else:
			direction = _slot_direction(slot)
		var closing: float = result.dot(-direction)
		if closing > 0.0:
			result += direction * closing
		if distance < ALLY_GAP:
			radial_push += direction * (1.0 - distance / ALLY_GAP)
		if distance > 0.05:
			# Rodea al compañero en vez de quedarse clavado detrás de él: el
			# puesto puede quedar justo al otro lado.
			var perpendicular: Vector3 = Vector3(-direction.z, 0.0, direction.x)
			var side: float = perpendicular.dot(result)
			if absf(side) < 0.05:
				side = 1.0 if posmod(slot, 2) == 0 else -1.0
			var weight: float = 1.0 - distance / ALLY_AVOID
			tangent_push += perpendicular * signf(side) * weight
	result += radial_push * SPEED * SEPARATION_PUSH
	result += tangent_push * SPEED * TANGENT_PUSH
	return result.limit_length(SPEED)


## Dirección estable para desempatar dos cuerpos exactamente superpuestos.
static func _slot_direction(slot: int) -> Vector3:
	var angle: float = TAU * float(posmod(slot, SLOT_COUNT)) / float(SLOT_COUNT)
	return Vector3(cos(angle), 0.0, sin(angle))
