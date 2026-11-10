extends RefCounted
## Comprueba la jerarquía y los tipos de la escena del jugador.


func test_player_scene_structure() -> bool:
	var packed: PackedScene = load("res://core/player/player_fps.tscn") as PackedScene
	if packed == null:
		return false
	var player: PlayerFPS = packed.instantiate() as PlayerFPS
	if player == null:
		return false
	var collision: CollisionShape3D = player.get_node_or_null("CollisionShape3D") as CollisionShape3D
	var head: Node3D = player.get_node_or_null("Head") as Node3D
	var camera: Camera3D = player.get_node_or_null("Head/Camera3D") as Camera3D
	var ray: RayCast3D = player.get_node_or_null("Head/Camera3D/InteractionRay") as RayCast3D
	var ok: bool = (
		collision != null
		and head != null
		and camera != null
		and ray != null
		and not ray.enabled
	)
	player.free()
	return ok
