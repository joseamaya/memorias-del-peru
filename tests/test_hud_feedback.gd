extends RefCounted
## Comprueba el aviso de pausa del HUD, la etiqueta de la barra de aliento, la
## tarjeta de fin (ADR-0013) y el resalte del interactuable enfocado, que vuelve a dejar la malla como
## estaba al perder el foco.


func test_hud_pause_and_stamina_label() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var hud: PlayerHud = (load("res://core/ui/hud.tscn") as PackedScene).instantiate() as PlayerHud
	tree.root.add_child(hud)
	var panel: Control = hud.get_node_or_null("PausePanel") as Control
	var label: Label = hud.get_node_or_null("PausePanel/PauseLabel") as Label
	var stamina_label: Label = hud.get_node_or_null("StaminaBar/StaminaLabel") as Label
	var ok: bool = panel != null and label != null and stamina_label != null
	if ok:
		ok = ok and not panel.visible and label.visible
		hud.show_pause(true)
		ok = ok and panel.visible and label.is_visible_in_tree()
		ok = ok and not tr(label.text).begins_with("UI_") and not tr(stamina_label.text).begins_with("UI_")
		hud.show_pause(false)
		ok = ok and not panel.visible
	hud.free()
	return ok


func test_interaction_highlight() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var highlighter: InteractionHighlight = InteractionHighlight.new()
	tree.root.add_child(highlighter)
	# Interactuable con malla propia.
	var object_root: Interactable = Interactable.new()
	var mesh: MeshInstance3D = MeshInstance3D.new()
	mesh.mesh = BoxMesh.new()
	var previous: StandardMaterial3D = StandardMaterial3D.new()
	mesh.material_overlay = previous
	object_root.add_child(mesh)
	tree.root.add_child(object_root)
	highlighter.highlight(object_root)
	var ok: bool = mesh.material_overlay == highlighter.glow_material()
	highlighter.clear()
	ok = ok and mesh.material_overlay == previous
	# Interactuable sin mallas (como «Hablar»): se resaltan las de su padre.
	var actor: Node3D = Node3D.new()
	var body: MeshInstance3D = MeshInstance3D.new()
	body.mesh = BoxMesh.new()
	actor.add_child(body)
	var talk: Interactable = Interactable.new()
	actor.add_child(talk)
	tree.root.add_child(actor)
	ok = ok and InteractionHighlight.meshes_for(talk).size() == 1
	highlighter.highlight(talk)
	ok = ok and body.material_overlay == highlighter.glow_material()
	highlighter.highlight(object_root)
	ok = ok and body.material_overlay == null and mesh.material_overlay == highlighter.glow_material()
	highlighter.clear()
	actor.free()
	object_root.free()
	highlighter.free()
	return ok


func test_end_card() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var world: Node = (load("res://campaigns/01_pachacutec/scenes/world/mundo_base.tscn") as PackedScene).instantiate()
	tree.root.add_child(world)
	var event: MessengerEvent = world.get_node("EventController") as MessengerEvent
	var hud: PlayerHud = world.get_node("UILayer/HUD") as PlayerHud
	var title: Label = world.get_node("UILayer/HUD/EndPanel/EndTitle") as Label
	var ok: bool = not world.call("is_end_card_shown") and not hud.is_end_card_visible()
	event.finished.emit()
	world.call("advance_end_card", 10.0)
	ok = ok and not hud.is_end_card_visible()
	world.call("advance_end_card", 45.0)
	ok = ok and world.call("is_end_card_shown") and hud.is_end_card_visible()
	ok = ok and title.text == tr("PCH_END_TITLE") and not title.text.begins_with("PCH_")
	hud.advance_end_card(3.0)
	var panel: ColorRect = world.get_node("UILayer/HUD/EndPanel") as ColorRect
	ok = ok and panel.color.a > 0.8 and title.modulate.a > 0.99
	world.free()
	return ok
