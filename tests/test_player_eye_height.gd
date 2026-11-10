extends RefCounted
## Comprueba que el origen del jugador está a los pies y los ojos a 1,60 m.


func test_player_eye_height() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	if packed == null:
		return false
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	tree.root.add_child(player)
	var head: Node3D = player.get_node_or_null("Head") as Node3D
	var camera: Camera3D = player.get_node_or_null("Head/Camera3D") as Camera3D
	var collision: CollisionShape3D = player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	if head == null or camera == null or collision == null:
		player.free()
		return false
	var capsule: CapsuleShape3D = collision.shape as CapsuleShape3D
	if capsule == null:
		player.free()
		return false
	var feet_y: float = collision.global_position.y - capsule.height * 0.5
	var ok: bool = is_equal_approx(camera.global_position.y, 1.6) and is_equal_approx(feet_y, 0.0)
	player.free()
	return ok
