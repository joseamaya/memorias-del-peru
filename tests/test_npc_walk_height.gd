extends RefCounted
## Comprueba que un NPC sigue la altura del suelo mientras camina, no solo al
## colocarlo en su ancla. La Y de la ruta se ignora cuando hay muestreador: la
## cuerda del navmesh puede quedar por encima o por debajo del terreno.


func test_walking_follows_ground_sampler() -> bool:
	var mover: NpcMover = NpcMover.new()
	mover.speed = 2.0
	mover.ground_sampler = func(x: float, _z: float) -> float: return x * 0.5
	var node: Node3D = Node3D.new()
	node.position = Vector3(0.0, mover.body_offset, 0.0)
	# La Y de la ruta es falsa a propósito: si se usara, el cuerpo flotaría.
	mover.set_path(PackedVector3Array([Vector3(4.0, 99.0, 0.0)]))
	var ok: bool = true
	for _step: int in 10:
		mover.advance(node, 0.2)
		ok = ok and absf(node.position.y - (node.position.x * 0.5 + mover.body_offset)) <= 0.001
	ok = ok and absf(node.position.x - 4.0) <= 0.01
	node.free()
	return ok


func test_walking_stays_on_slope_at_every_step() -> bool:
	var mover: NpcMover = NpcMover.new()
	mover.speed = 1.0
	mover.ground_sampler = func(_x: float, z: float) -> float: return z * 0.25
	var node: Node3D = Node3D.new()
	node.position = Vector3(0.0, mover.body_offset, 0.0)
	mover.set_path(PackedVector3Array([Vector3(0.0, 0.0, 2.0)]))
	var ok: bool = true
	for _step: int in 5:
		mover.advance(node, 0.2)
		ok = ok and absf(node.position.y - (node.position.z * 0.25 + mover.body_offset)) <= 0.001
	node.free()
	return ok
