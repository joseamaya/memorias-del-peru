extends RefCounted
## Comprueba que las lomas del campo no tocan la llacta: cota 0 en la plaza,
## las casas, las terrazas y los caminos, y relieve en el campo abierto.

const FLAT_POINTS: Array[Vector2] = [
	Vector2(0.0, 0.0), # plaza
	Vector2(-27.0, 6.0), # casa más alejada del oeste
	Vector2(23.0, 15.0), # casa más alejada del este
	Vector2(54.0, 14.0), # esquina de la última terraza
	Vector2(30.0, -17.0), # esquina de la primera terraza
	Vector2(0.0, 45.0), # inicio en el camino sur
	Vector2(0.0, -60.0), # camino norte, donde espera el mensajero
	Vector2(-34.0, 0.0), # final del camino oeste
	Vector2(3.2, 18.0), # vecino que recibe
]


func test_terrain_relief() -> bool:
	var ok: bool = true
	for point: Vector2 in FLAT_POINTS:
		ok = ok and is_zero_approx(MundoBase.relief_height_at(point.x, point.y))
	var max_relief: float = 0.0
	for x: int in range(-60, 61, 5):
		for z: int in range(-60, 61, 5):
			max_relief = maxf(max_relief, absf(MundoBase.relief_height_at(float(x), float(z))))
	ok = ok and max_relief > 0.5 and max_relief <= MundoBase.RELIEF_AMPLITUDE * 1.5
	return ok
