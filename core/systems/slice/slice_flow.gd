class_name SliceFlow
extends RefCounted
## Progreso puro por una [SliceSequence].
##
## No conoce nodos ni escenas: decide qué paso toca, salta los que no aplican
## por sus banderas y recuerda las banderas y el checkpoint. Así las pruebas
## pueden recorrer la secuencia sin cargar el mundo.

var _steps: Array[SliceStep] = []
var _index: int = 0
var _flags: Array[StringName] = []
var _checkpoint: StringName = &""


func _init(sequence: SliceSequence) -> void:
	_steps = sequence.steps
	_settle()


func current() -> SliceStep:
	return _steps[_index] if _index < _steps.size() else null


func index() -> int:
	return _index


func is_finished() -> bool:
	return _index >= _steps.size()


## Completa el paso actual, deja sus banderas y pasa al siguiente que aplique.
func advance(extra_flag: StringName = &"") -> SliceStep:
	if not is_finished():
		set_flag(_steps[_index].flag)
		set_flag(extra_flag)
		_index += 1
		_settle()
	return current()


## El siguiente paso que aplicaría con las banderas actuales.
func peek_next() -> SliceStep:
	for i: int in range(_index + 1, _steps.size()):
		if applies(_steps[i]):
			return _steps[i]
	return null


## Bandera que deja el paso actual, o vacía.
func current_flag() -> StringName:
	var step: SliceStep = current()
	return step.flag if step != null else &""


func count() -> int:
	return _steps.size()


func set_flag(flag: StringName) -> void:
	if flag != &"" and not _flags.has(flag):
		_flags.append(flag)


func has_flag(flag: StringName) -> bool:
	return _flags.has(flag)


func applies(step: SliceStep) -> bool:
	if step.only_if != &"" and not has_flag(step.only_if):
		return false
	return step.unless == &"" or not has_flag(step.unless)


func act() -> SliceStep.Act:
	if _steps.is_empty():
		return SliceStep.Act.OPENING
	return _steps[mini(_index, _steps.size() - 1)].act


func checkpoint() -> StringName:
	return _checkpoint


func _settle() -> void:
	while _index < _steps.size() and not applies(_steps[_index]):
		_index += 1
	if _index < _steps.size() and _steps[_index].checkpoint != &"":
		_checkpoint = _steps[_index].checkpoint
