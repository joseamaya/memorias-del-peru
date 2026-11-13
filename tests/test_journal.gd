extends RefCounted
## Comprueba el diario: encargos, Memoria, sellos y duplicados (ADR-0038).


func test_journal_memory() -> bool:
	var journal: Journal = Journal.new()
	var ok: bool = journal.add_memory(&"mem_quero", &"MEM_QUERO_TITLE", &"MEM_QUERO_BODY", &"H", &"PCH-004")
	ok = ok and journal.has(&"mem_quero")
	ok = ok and journal.count() == 1
	var entries: Array[JournalEntry] = journal.get_entries(JournalEntry.Kind.MEMORY)
	ok = ok and entries.size() == 1
	ok = ok and entries[0].badge == &"H"
	ok = ok and entries[0].source_key == &"PCH-004"
	ok = ok and journal.get_entries(JournalEntry.Kind.QUEST).is_empty()
	journal.free()
	return ok


func test_journal_rejects_invalid_memory() -> bool:
	var journal: Journal = Journal.new()
	var ok: bool = not journal.add_memory(&"", &"T", &"B", &"H", &"PCH-004")
	ok = ok and not journal.add_memory(&"mem", &"", &"B", &"H", &"PCH-004")
	ok = ok and not journal.add_memory(&"mem", &"T", &"B", &"X", &"PCH-004")
	ok = ok and not journal.add_memory(&"mem", &"T", &"B", &"R", &"")
	ok = ok and journal.count() == 0
	journal.free()
	return ok


func test_journal_duplicates() -> bool:
	var journal: Journal = Journal.new()
	var ok: bool = journal.add_memory(&"mem", &"T", &"B", &"R", &"PCH-022")
	ok = ok and not journal.add_memory(&"mem", &"T2", &"B2", &"A", &"PCH-002")
	ok = ok and not journal.add_quest(&"mem", &"Q", &"Q_BODY")
	ok = ok and journal.count() == 1
	journal.free()
	return ok


func test_journal_quest() -> bool:
	var journal: Journal = Journal.new()
	var completed: Array[StringName] = []
	journal.quest_completed.connect(func(entry: JournalEntry) -> void: completed.append(entry.id))
	var ok: bool = journal.add_quest(&"q_agua", &"Q_AGUA_TITLE", &"Q_AGUA_BODY")
	ok = ok and journal.has(&"q_agua")
	ok = ok and not journal.is_done(&"q_agua")
	ok = ok and journal.complete_quest(&"q_agua")
	ok = ok and journal.is_done(&"q_agua")
	ok = ok and completed == [&"q_agua"]
	ok = ok and not journal.complete_quest(&"q_agua")
	ok = ok and not journal.complete_quest(&"no_existe")
	journal.free()
	return ok


func test_journal_clear() -> bool:
	var journal: Journal = Journal.new()
	journal.add_quest(&"q", &"T", &"B")
	journal.add_memory(&"m", &"T", &"B", &"N", &"PCH-023")
	journal.clear()
	var ok: bool = journal.count() == 0 and not journal.has(&"q")
	journal.free()
	return ok
