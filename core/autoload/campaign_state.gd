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
