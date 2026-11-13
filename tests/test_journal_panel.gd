extends RefCounted
## Comprueba el panel del diario: entradas, detalle, sello y fuente (ADR-0038).

const SCENE_PATH: String = "res://core/ui/journal_panel.tscn"


func _spawn() -> JournalPanel:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	var packed: PackedScene = load(SCENE_PATH) as PackedScene
	if packed == null:
		return null
	var panel: JournalPanel = packed.instantiate() as JournalPanel
	tree.root.add_child(panel)
	return panel


func test_journal_panel_entries() -> bool:
	var journal: Journal = Journal.new()
	journal.add_quest(&"q_agua", &"Q_AGUA_TITLE", &"Q_AGUA_BODY")
	journal.add_memory(&"mem_telar", &"PCH_ST_TELAR_TITLE", &"PCH_ST_TELAR_BODY", &"A", &"PCH-010")
	var panel: JournalPanel = _spawn()
	if panel == null:
		journal.free()
		return false
	panel.open(journal)
	var ok: bool = panel.is_open() and panel.get_entry_count() == 2
	panel.select_entry(1)
	ok = ok and panel.get_detail_title() == tr("PCH_ST_TELAR_TITLE")
	ok = ok and panel.get_detail_text() == tr("PCH_ST_TELAR_BODY")
	panel.close()
	ok = ok and not panel.is_open()
	panel.free()
	journal.free()
	return ok


func test_journal_panel_empty() -> bool:
	var journal: Journal = Journal.new()
	var panel: JournalPanel = _spawn()
	if panel == null:
		journal.free()
		return false
	panel.open(journal)
	var ok: bool = panel.get_entry_count() == 0
	ok = ok and panel.get_detail_text() == tr("UI_JOURNAL_EMPTY")
	panel.free()
	journal.free()
	return ok
