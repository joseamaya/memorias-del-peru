class_name JournalEntry
extends Resource
## Entrada del diario: un encargo o una entrada de «Memoria».
##
## Guarda claves de localización, no textos. Las entradas de Memoria llevan
## sello de clasificación H/A/R/N y fuente.

enum Kind {
	QUEST,
	MEMORY,
}

var id: StringName = &""
var title_key: StringName = &""
var body_key: StringName = &""
var badge: StringName = &""
var source_key: StringName = &""
var kind: Kind = Kind.QUEST
var done: bool = false


func _init(
	entry_id: StringName = &"",
	entry_title: StringName = &"",
	entry_body: StringName = &"",
	entry_badge: StringName = &"",
	entry_source: StringName = &"",
	entry_kind: Kind = Kind.QUEST
) -> void:
	id = entry_id
	title_key = entry_title
	body_key = entry_body
	badge = entry_badge
	source_key = entry_source
	kind = entry_kind
