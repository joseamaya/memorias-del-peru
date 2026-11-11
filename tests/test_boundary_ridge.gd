extends RefCounted
## Comprueba la cresta del borde: el interior, el inicio y el paso norte del
## mensajero quedan a nivel; el borde sube más de 8 m y su ladera supera los
## 45° (límite de pendiente transitable del CharacterBody3D por defecto).

const WORLD_SCRIPT: String = "res://campaigns/01_pachacutec/scripts/world/mundo_base.gd"


func _ridge(world_script: GDScript, x: float, z: float) -> float:
	var height: float = world_script.call("ridge_height_at", x, z)
	return height


func test_boundary_ridge() -> bool:
	var world_script: GDScript = load(WORLD_SCRIPT) as GDScript
	if world_script == null:
		return false
	var ok: bool = true
	# Interior, inicio (camino sur) y terrazas: sin cresta.
	for point: Vector2 in [Vector2(0, 0), Vector2(0, 45), Vector2(40, 40), Vector2(50, 0)]:
		ok = ok and is_zero_approx(_ridge(world_script, point.x, point.y))
	# Paso norte: el mensajero sale de z = -60 y la comitiva sale por z = -52.
	for z: float in [-52.0, -60.0, -66.0, -74.0]:
		ok = ok and _ridge(world_script, 0.0, z) < 0.5
	# Borde en los cuatro lados (fuera del paso): más de 8 m.
	for point: Vector2 in [Vector2(72, 0), Vector2(-72, 0), Vector2(0, 72), Vector2(25, -72)]:
		ok = ok and _ridge(world_script, point.x, point.y) > 8.0
	# Ladera: en el tramo central sube más de 1 m por metro (> 45°).
	var slope: float = (_ridge(world_script, 68.0, 0.0) - _ridge(world_script, 66.0, 0.0)) / 2.0
	ok = ok and slope > 1.0
	return ok
