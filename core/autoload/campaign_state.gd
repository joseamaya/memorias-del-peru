class_name CampaignStateService
extends Node
## Banderas de la campaña que sobreviven a los cambios de escena.
##
## Las decisiones del acto II (herido, maíz, descanso) tienen que llegar al
## acto III. Este autoload guarda enteros por clave; no escribe en disco
## todavía: el guardado completo sigue fuera de alcance. `clear()` reinicia la
## campaña.

signal flag_changed(key: StringName, value: int)

var _flags: Dictionary[StringName, int] = {}
var _data: Dictionary[StringName, Variant] = {}


## Devuelve el autoload, o `null` si no existe.
static func instance() -> CampaignStateService:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return null
	return tree.root.get_node_or_null("CampaignState") as CampaignStateService


## Fija una bandera y emite el cambio.
func set_flag(key: StringName, value: int = 1) -> void:
	if key == &"":
		return
	if get_flag(key) == value:
		return
	if value == 0:
		_flags.erase(key)
	else:
		_flags[key] = value
	flag_changed.emit(key, value)


## Valor de una bandera; 0 si no existe.
func get_flag(key: StringName) -> int:
	return _flags.get(key, 0)


## Indica si la bandera tiene un valor distinto de cero.
func has_flag(key: StringName) -> bool:
	return get_flag(key) != 0


## Copia de todas las banderas.
func get_flags() -> Dictionary[StringName, int]:
	return _flags.duplicate()


## Guarda un dato de campaña que no es una bandera (inventario, oficio, punto
## de control). El llamador no debe mutar el valor después de guardarlo.
func set_data(key: StringName, value: Variant) -> void:
	if key == &"":
		return
	if value == null:
		_data.erase(key)
		return
	_data[key] = value


## Devuelve un dato de campaña, o [param default_value] si no existe.
func get_data(key: StringName, default_value: Variant = null) -> Variant:
	return _data.get(key, default_value)


## Indica si existe un dato de campaña.
func has_data(key: StringName) -> bool:
	return _data.has(key)


## Borra todas las banderas y datos; se llama al empezar una campaña nueva.
func clear() -> void:
	_flags.clear()
	_data.clear()


## Estado serializable, con claves String para JSON.
##
## Los datos (`set_data`) deben ser valores serializables: números, textos,
## listas y diccionarios. Un `StringName` se guarda como texto.
func to_dict() -> Dictionary:
	var flags: Dictionary = {}
	for key: StringName in _flags.keys():
		flags[String(key)] = _flags[key]
	var data: Dictionary = {}
	for key: StringName in _data.keys():
		data[String(key)] = _to_json_value(_data[key])
	return {"flags": flags, "data": data}


## Restaura el estado. Devuelve `false` si la estructura no es válida.
func from_dict(data: Dictionary) -> bool:
	var flags_value: Variant = data.get("flags", {})
	var data_value: Variant = data.get("data", {})
	if not (flags_value is Dictionary) or not (data_value is Dictionary):
		return false
	clear()
	var flags: Dictionary = _as_dict(flags_value)
	for key: Variant in flags.keys():
		_flags[StringName(str(key))] = _to_int(flags[key])
	var values: Dictionary = _as_dict(data_value)
	for key: Variant in values.keys():
		_data[StringName(str(key))] = values[key]
	return true


static func _to_json_value(value: Variant) -> Variant:
	if value is StringName:
		return str(value)
	if value is Dictionary:
		var source: Dictionary = _as_dict(value)
		var result: Dictionary = {}
		for key: Variant in source.keys():
			result[str(key)] = _to_json_value(source[key])
		return result
	if value is Array:
		var list: Array = []
		for item: Variant in _as_array(value):
			list.append(_to_json_value(item))
		return list
	return value


func _to_int(value: Variant) -> int:
	if value is bool:
		return 1 if value else 0
	var text: String = str(value)
	if text.is_valid_int():
		return int(text)
	if text.is_valid_float():
		return int(text.to_float())
	return 0


# El origen es JSON; la comprobación `is Dictionary` se hace antes de llamar.
# Se concentra aquí la única supresión necesaria.
static func _as_dict(value: Variant) -> Dictionary:
	@warning_ignore("unsafe_cast")
	return value as Dictionary


# Igual que `_as_dict`, para listas.
static func _as_array(value: Variant) -> Array:
	@warning_ignore("unsafe_cast")
	return value as Array
