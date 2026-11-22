extends RefCounted
## El aviso de interacción debe desaparecer al perder el foco.

const HUD_PATH: String = "res://core/ui/hud.tscn"


func test_unfocus_clears_interaction_hint() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var packed: PackedScene = load(HUD_PATH) as PackedScene
	if packed == null:
		return false
	var hud: PlayerHud = packed.instantiate() as PlayerHud
	if hud == null:
		return false
	tree.root.add_child(hud)
	var talk: Interactable = Interactable.new()
	hud.call("_on_interactable_focused", talk)
	var ok: bool = hud.interaction_label.visible
	ok = ok and not hud.interaction_label.text.is_empty()
	hud.call("_on_interactable_unfocused")
	ok = ok and not hud.interaction_label.visible
	ok = ok and hud.interaction_label.text.is_empty()
	talk.free()
	hud.free()
	return ok
