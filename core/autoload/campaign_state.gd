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


## Borra todas las banderas; se llama al empezar una campaña nueva.
func clear() -> void:
	_flags.clear()
