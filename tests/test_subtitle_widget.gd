extends RefCounted
## Comprueba el widget de subtítulos del HUD (ADR-0006).


func test_subtitle_widget() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://core/ui/hud.tscn") as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	hud.show_subtitle("Los chancas avanzan", 2.0)
	var label: Label = hud.get_node_or_null("SubtitleLabel") as Label
	if label == null:
		hud.free()
		return false
	var shown: bool = label.visible and label.text == "Los chancas avanzan"
	hud.advance_subtitle(1.5)
	var still_shown: bool = label.visible
	hud.advance_subtitle(1.0)
	var hidden: bool = not label.visible
	hud.show_subtitle("Otra vez", 3.0)
	hud.clear_subtitle()
	var cleared: bool = not label.visible and label.text.is_empty()
	hud.free()
	return shown and still_shown and hidden and cleared


func test_hud_shows_opening() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene
	if packed == null:
		return false
	var world: Node = packed.instantiate()
	tree.root.add_child(world)
	var label: Label = world.get_node_or_null("UILayer/HUD/SubtitleLabel") as Label
	if label == null:
		world.free()
		return false
	var text: String = label.text
	var ok: bool = label.visible and not text.is_empty() and not text.begins_with("PCH_")
	world.free()
	return ok
