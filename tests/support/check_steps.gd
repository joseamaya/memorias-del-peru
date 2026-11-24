class_name CheckSteps
extends RefCounted
## Registro con nombre de los pasos de un recorrido de integración.
##
## Los recorridos imprimían solo `<TAG>_FAIL`, sin decir qué comprobación había
## fallado. Cada paso deja su etiqueta y el resumen final nombra los fallidos.

var _passed: int = 0
var _failed: Array[String] = []


## Registra una comprobación y devuelve su resultado.
func check(label: String, condition: bool) -> bool:
	if condition:
		_passed += 1
	else:
		_failed.append(label)
		printerr("FALLO ", label)
	return condition


## Indica si todas las comprobaciones registradas pasaron.
func is_ok() -> bool:
	return _failed.is_empty()


## Pasos que pasaron.
func get_passed() -> int:
	return _passed


## Etiquetas de los pasos que fallaron.
func get_failed() -> Array[String]:
	return _failed.duplicate()


## Imprime `<TAG>_OK` o el resumen con las etiquetas fallidas.
func report(tag: String) -> void:
	if _failed.is_empty():
		print(tag, "_OK pasos=", _passed)
		return
	printerr(tag, "_FAIL fallidos=", _failed.size(), " de ", _passed + _failed.size())
	for label: String in _failed:
		printerr("  - ", label)
