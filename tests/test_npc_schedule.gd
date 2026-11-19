extends RefCounted
## Comprueba el horario de NPC por franjas y condiciones (F1.5).


func test_npc_schedule_day() -> bool:
	var npc: NpcDefinition = _build_npc()
	var ok: bool = npc.get_activity(0) == &"dormir"
	ok = ok and npc.get_activity(400) == &"trabajar"
	ok = ok and npc.get_activity(1200) == &"casa"
	ok = ok and npc.get_anchor(400) == &"campo"
	ok = ok and npc.get_anchor(1200) == &"casa"
	return ok


func test_npc_schedule_wrap() -> bool:
	var entry: ScheduleEntry = ScheduleEntry.new()
	entry.start_minute = 1320
	entry.end_minute = 360
	entry.anchor_id = &"casa"
	entry.activity = &"dormir"
	var ok: bool = entry.contains(1380)
	ok = ok and entry.contains(60)
	ok = ok and not entry.contains(600)
	return ok


func test_npc_schedule_conditions() -> bool:
	var npc: NpcDefinition = NpcDefinition.new()
	npc.id = &"npc_prueba"
	npc.home_anchor = &"casa"
	var normal: ScheduleEntry = ScheduleEntry.new()
	normal.start_minute = 0
	normal.end_minute = 1440
	normal.anchor_id = &"plaza"
	normal.activity = &"pasear"
	var wartime: ScheduleEntry = ScheduleEntry.new()
	wartime.start_minute = 0
	wartime.end_minute = 1440
	wartime.anchor_id = &"refugio"
	wartime.activity = &"esconderse"
	wartime.conditions[&"fase"] = 2
	npc.schedule.append(wartime)
	npc.schedule.append(normal)
	var war_conditions: Dictionary[StringName, int] = {&"fase": 2}
	var peace_conditions: Dictionary[StringName, int] = {&"fase": 0}
	var ok: bool = npc.get_anchor(600, war_conditions) == &"refugio"
	ok = ok and npc.get_activity(600, war_conditions) == &"esconderse"
	ok = ok and npc.get_anchor(600, peace_conditions) == &"plaza"
	return ok


func test_npc_schedule_fallback_and_validity() -> bool:
	var npc: NpcDefinition = NpcDefinition.new()
	var ok: bool = not npc.is_valid()
	npc.id = &"npc_prueba"
	npc.home_anchor = &"casa"
	ok = ok and npc.is_valid()
	ok = ok and npc.get_entry(600) == null
	ok = ok and npc.get_anchor(600) == &"casa"
	ok = ok and npc.get_activity(600) == &"idle"
	var invalid: ScheduleEntry = ScheduleEntry.new()
	npc.schedule.append(invalid)
	ok = ok and not npc.is_valid()
	return ok


func _build_npc() -> NpcDefinition:
	var npc: NpcDefinition = NpcDefinition.new()
	npc.id = &"npc_prueba"
	npc.name_key = &"NPC_PRUEBA"
	npc.home_anchor = &"casa"
	npc.work_anchor = &"campo"
	var sleep: ScheduleEntry = _entry(0, 360, &"casa", &"dormir")
	var work: ScheduleEntry = _entry(360, 1080, &"campo", &"trabajar")
	var home: ScheduleEntry = _entry(1080, 1440, &"casa", &"casa")
	npc.schedule.append(sleep)
	npc.schedule.append(work)
	npc.schedule.append(home)
	return npc


func _entry(start: int, end: int, anchor: StringName, activity: StringName) -> ScheduleEntry:
	var entry: ScheduleEntry = ScheduleEntry.new()
	entry.start_minute = start
	entry.end_minute = end
	entry.anchor_id = anchor
	entry.activity = activity
	return entry
