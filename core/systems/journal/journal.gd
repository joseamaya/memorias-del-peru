class_name Journal
extends Node
## Diario del jugador: encargos activos y «Memoria» histórica.
##
## Sustituye a las tarjetas del museo (ADR-0038). No conoce la UI ni la campaña:
## guarda claves de localización, sello de clasificación y fuente, y emite
## [signal changed]. La UI decide cómo mostrarlo.
##
## Reglas:
## - Los identificadores son únicos en todo el diario.
## - Una entrada de Memoria exige sello H/A/R/N y fuente; sin ellos no entra.
## - Completar un encargo no lo borra: lo marca como hecho.

signal changed
signal entry_added(entry: JournalEntry)
signal quest_completed(entry: JournalEntry)

## Sellos de clasificación histórica admitidos ([docs/07](../../../docs/07_convenciones_historicas.md)).
const BADGES: Array[StringName] = [&"H", &"A", &"R", &"N"]

var _entries: Array[JournalEntry] = []


## Añade una entrada de Memoria. Devuelve `false` si los datos no son válidos o
## el identificador ya existe.
func add_memory(
	entry_id: StringName,
	title_key: StringName,
	body_key: StringName,
	badge: StringName,
	source_key: StringName
) -> bool:
	if entry_id == &"" or title_key == &"" or body_key == &"" or source_key == &"":
		return false
	if not BADGES.has(badge):
		return false
	return _add(JournalEntry.new(entry_id, title_key, body_key, badge, source_key, JournalEntry.Kind.MEMORY))


## Añade un encargo activo. Devuelve `false` si faltan datos o el identificador
## ya existe.
func add_quest(entry_id: StringName, title_key: StringName, body_key: StringName) -> bool:
	if entry_id == &"" or title_key == &"" or body_key == &"":
		return false
	return _add(JournalEntry.new(entry_id, title_key, body_key, &"", &"", JournalEntry.Kind.QUEST))


## Marca un encargo como cumplido. Devuelve `false` si no existe o no es un
## encargo.
func complete_quest(entry_id: StringName) -> bool:
	var entry: JournalEntry = get_entry(entry_id)
	if entry == null or entry.kind != JournalEntry.Kind.QUEST or entry.done:
		return false
	entry.done = true
	quest_completed.emit(entry)
	changed.emit()
	return true


## Indica si existe una entrada con ese identificador.
func has(entry_id: StringName) -> bool:
	return get_entry(entry_id) != null


## Devuelve la entrada, o `null` si no existe.
func get_entry(entry_id: StringName) -> JournalEntry:
	for entry: JournalEntry in _entries:
		if entry.id == entry_id:
			return entry
	return null


## Indica si una entrada existe y está cumplida.
func is_done(entry_id: StringName) -> bool:
	var entry: JournalEntry = get_entry(entry_id)
	return entry != null and entry.done


## Devuelve una copia de las entradas, opcionalmente filtradas por tipo.
func get_entries(kind: int = -1) -> Array[JournalEntry]:
	var result: Array[JournalEntry] = []
	for entry: JournalEntry in _entries:
		if kind >= 0 and entry.kind != kind:
			continue
		result.append(entry)
	return result


## Número de entradas.
func count() -> int:
	return _entries.size()


## Vacía el diario.
func clear() -> void:
	_entries.clear()
	changed.emit()


func _add(entry: JournalEntry) -> bool:
	if has(entry.id):
		return false
	_entries.append(entry)
	entry_added.emit(entry)
	changed.emit()
	return true
