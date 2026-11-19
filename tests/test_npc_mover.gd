extends RefCounted
## Comprueba el seguidor de rutas de NPC.


func test_npc_mover_follows_path() -> bool:
	var node: Node3D = Node3D.new()
	node.position = Vector3(0.0, 0.9, 0.0)
	var mover: NpcMover = NpcMover.new()
	mover.speed = 2.0
	mover.set_path(PackedVector3Array([Vector3(2.0, 0.0, 0.0), Vector3(2.0, 0.5, 2.0)]))
	var ok: bool = not mover.is_finished()
	mover.advance(node, 0.5)
	ok = ok and node.position.distance_to(Vector3(1.0, 0.9, 0.0)) < 0.01
	mover.advance(node, 10.0)
	ok = ok and mover.is_finished()
	ok = ok and node.position.distance_to(Vector3(2.0, 1.4, 2.0)) < 0.01
	node.free()
	return ok


func test_npc_mover_empty_path() -> bool:
	var node: Node3D = Node3D.new()
	var mover: NpcMover = NpcMover.new()
	mover.set_path(PackedVector3Array())
	var ok: bool = mover.is_finished()
	mover.advance(node, 1.0)
	ok = ok and node.position.is_equal_approx(Vector3.ZERO)
	node.free()
	return ok
