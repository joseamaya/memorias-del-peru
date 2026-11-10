extends RefCounted
## Comprueba que el controlador aplica el perfil al Environment.


func test_environment_quality_controller() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var world_environment: WorldEnvironment = world.get_node_or_null("WorldEnvironment") as WorldEnvironment
	var sun: DirectionalLight3D = world.get_node_or_null("Inti") as DirectionalLight3D
	var settings: GraphicsSettingsService = GraphicsSettings
	var ultra: GraphicsProfile = load("res://core/systems/graphics/profiles/ultra.tres") as GraphicsProfile
	if world_environment == null or sun == null or settings == null or ultra == null:
		world.free()
		return false
	var environment: Environment = world_environment.environment
	settings.set_profile(ultra)
	var ok: bool = (
		environment != null
		and environment.volumetric_fog_enabled
		and environment.ssao_enabled
		and environment.sdfgi_enabled
		and is_equal_approx(sun.directional_shadow_max_distance, ultra.shadow_distance)
	)
	settings.set_profile_by_index(0)
	world.free()
	return ok
