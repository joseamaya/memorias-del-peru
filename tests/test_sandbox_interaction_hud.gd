extends RefCounted
## Comprueba la cadena completa jugador → quero → HUD en el sandbox.


func test_sandbox_interaction_hud() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://tests/scenes/player_sandbox.tscn") as PackedScene
	if packed == null:
		return false
	var sandbox: Node = packed.instantiate()
	var player: PlayerFPS = sandbox.get_node_or_null("PlayerFPS") as PlayerFPS
	if player == null:
		sandbox.free()
		return false
	var head: Node3D = player.get_node_or_null("Head") as Node3D
	if head == null:
		sandbox.free()
		return false
	player.position = Vector3(0.9, 0.05, 7.6)
	head.rotation.x = deg_to_rad(-30.0)
	tree.root.add_child(sandbox)
	var hud: PlayerHud = sandbox.get_node_or_null("UILayer/HUD") as PlayerHud
	if hud == null:
		sandbox.free()
		return false
	player.interaction_ray.force_raycast_update()
	player.update_interaction()
	var ok: bool = hud.interaction_label.visible and hud.interaction_label.text == "Beber chicha"
	sandbox.free()
	return ok
