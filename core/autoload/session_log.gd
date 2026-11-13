class_name SessionLogService
extends Node
## Registro de una sesión de prueba del vertical slice.
##
## Se activa con el argumento de usuario `--session <código>` o
## `--session=<código>`, por ejemplo:
##
##     godot --path . -- --session PIL-2
##
## Escribe `user://sesiones/<código>.log` con una línea por marca y la hora
## transcurrida, para que la duración y los hitos del protocolo
## ([alcance §9.2](../../campaigns/01_pachacutec/documentation/alcance_vertical_slice.md))
## no dependan del cronómetro del facilitador. También anexa los mensajes de
## error y advertencia del motor, de modo que la comprobación de «cero errores
## en consola» (§9.6) quede en el propio archivo.
##
## Fuera de una sesión no escribe nada ni altera el juego.

## Carpeta de los registros, relativa a `user://`.
const SESSION_DIR: String = "user://sesiones"
## Argumento que activa el registro.
const ARG_NAME: String = "--session"
## Variante con el código en el mismo argumento.
const ARG_PREFIX: String = "--session="
## Longitud máxima del código de sesión.
const MAX_CODE_LENGTH: int = 24

## Hay una sesión en curso y se está escribiendo el registro.
var active: bool = false

var _code: String = ""
var _directory: String = SESSION_DIR
var _file: FileAccess = null
var _start_ticks: int = 0
var _logger: SessionErrorLogger = null
var _mutex: Mutex = Mutex.new()
var _engine_messages: Array[String] = []


## Recibe los mensajes del motor para anexarlos al registro.
##
## [method Logger._log_message] se llama desde otros hilos, así que solo se
## encola bajo mutex; el volcado al archivo ocurre en [method _process].
class SessionErrorLogger extends Logger:
	var sink: Callable = Callable()

	func _log_message(message: String, error: bool) -> void:
		if error and sink.is_valid():
			sink.call(message)

	func _log_error(
		_function: String,
		file: String,
		line: int,
		code: String,
		rationale: String,
		_editor_notify: bool,
		error_type: int,
		_script_backtraces: Array[ScriptBacktrace]
	) -> void:
		if not sink.is_valid():
			return
		var kind: String = "error"
		match error_type:
			Logger.ERROR_TYPE_WARNING:
				kind = "aviso"
			Logger.ERROR_TYPE_SCRIPT:
				kind = "error de script"
			Logger.ERROR_TYPE_SHADER:
				kind = "error de shader"
		var text: String = code if not code.is_empty() else rationale
		sink.call(kind + ": " + text + " (" + file + ":" + str(line) + ")")


func _ready() -> void:
	set_process(false)
	var code: String = _code_from_args()
	if code.is_empty():
		return
	if not is_valid_code(code):
		printerr("Sesión: código inválido «", code, "» (letras, números, «-» o «_»).")
		return
	if not start(code):
		printerr("Sesión: no se pudo crear el registro en ", SESSION_DIR, ".")


func _process(_delta: float) -> void:
	_flush_engine_messages()


func _exit_tree() -> void:
	finish("salida")


## Indica si hay una sesión activa.
func is_active() -> bool:
	return active


## Código de la sesión activa, o cadena vacía.
func get_code() -> String:
	return _code


## Ruta absoluta del registro, o cadena vacía si no hay sesión activa.
func get_log_path() -> String:
	if _code.is_empty():
		return ""
	return ProjectSettings.globalize_path(_directory.path_join(_code + ".log"))


## Empieza a registrar una sesión con [param code].
##
## [param directory] permite a las pruebas escribir en una carpeta temporal.
## Devuelve `false` si ya había una sesión, si el código no es válido o si no
## se pudo abrir el archivo.
func start(code: String, directory: String = SESSION_DIR) -> bool:
	if active or not is_valid_code(code):
		return false
	var absolute_dir: String = ProjectSettings.globalize_path(directory)
	var error: Error = DirAccess.make_dir_recursive_absolute(absolute_dir)
	if error != OK and error != ERR_ALREADY_EXISTS:
		return false
	_file = FileAccess.open(directory.path_join(code + ".log"), FileAccess.WRITE)
	if _file == null:
		return false
	_code = code
	_directory = directory
	_start_ticks = Time.get_ticks_msec()
	active = true
	_write_header(directory)
	_logger = SessionErrorLogger.new()
	_logger.sink = _on_engine_message
	OS.add_logger(_logger)
	set_process(true)
	mark(&"session_start")
	return true


## Añade una marca al registro con el tiempo transcurrido.
##
## [param detail] se escribe en una tercera columna; los saltos de línea se
## sustituyen para mantener una línea por marca.
func mark(event: StringName, detail: String = "") -> void:
	if not active:
		return
	var stamp: String = _stamp()
	var line: String = stamp + "\t" + String(event)
	var clean_detail: String = detail.replace("\n", " ").replace("\r", " ").strip_edges()
	if not clean_detail.is_empty():
		line += "\t" + clean_detail
	_write_raw(line + "\n")
	if clean_detail.is_empty():
		print("[SESION] ", stamp, " ", String(event))
	else:
		print("[SESION] ", stamp, " ", String(event), " ", clean_detail)


## Cierra el registro, si hay uno abierto.
func finish(reason: String = "") -> void:
	if not active:
		return
	_flush_engine_messages()
	mark(&"session_end", reason)
	active = false
	if _logger != null:
		OS.remove_logger(_logger)
		_logger = null
	if _file != null:
		_file.flush()
		_file.close()
		_file = null
	set_process(false)


## Comprueba que un código solo use letras, números, guion y guion bajo.
static func is_valid_code(code: String) -> bool:
	if code.is_empty() or code.length() > MAX_CODE_LENGTH:
		return false
	for index: int in range(code.length()):
		var character: int = code.unicode_at(index)
		var is_digit: bool = character >= 48 and character <= 57
		var is_upper: bool = character >= 65 and character <= 90
		var is_lower: bool = character >= 97 and character <= 122
		var is_separator: bool = character == 45 or character == 95
		if not (is_digit or is_upper or is_lower or is_separator):
			return false
	return true


func _code_from_args() -> String:
	var args: PackedStringArray = OS.get_cmdline_user_args()
	for index: int in range(args.size()):
		var argument: String = args[index]
		if argument.begins_with(ARG_PREFIX):
			return argument.substr(ARG_PREFIX.length()).strip_edges()
		if argument == ARG_NAME and index + 1 < args.size():
			return args[index + 1].strip_edges()
	return ""


func _write_header(directory: String) -> void:
	var version: Dictionary = Engine.get_version_info()
	_write_raw("# Sesión de prueba — Memorias del Perú\n")
	_write_raw("# Código: " + _code + "\n")
	_write_raw("# Inicio: " + Time.get_datetime_string_from_system(false, true) + "\n")
	_write_raw("# Godot: " + str(version.get("string", "")) + "\n")
	_write_raw("# Carpeta: " + directory + "\n")
	_write_raw("# Formato: +MM:SS.mmm<TAB>marca<TAB>detalle\n")


func _stamp() -> String:
	var total: int = Time.get_ticks_msec() - _start_ticks
	var minutes: int = total / 60000
	var seconds: int = (total % 60000) / 1000
	var millis: int = total % 1000
	return "+%02d:%02d.%03d" % [minutes, seconds, millis]


func _write_raw(text: String) -> void:
	if _file == null:
		return
	_file.store_string(text)
	_file.flush()


func _on_engine_message(message: String) -> void:
	if not active:
		return
	var clean: String = message.strip_edges().replace("\n", " | ").replace("\r", "")
	if clean.is_empty():
		return
	_mutex.lock()
	_engine_messages.append(_stamp() + "\tconsole\t" + clean)
	_mutex.unlock()


func _flush_engine_messages() -> void:
	if _engine_messages.is_empty():
		return
	_mutex.lock()
	var lines: Array[String] = _engine_messages.duplicate()
	_engine_messages.clear()
	_mutex.unlock()
	for line: String in lines:
		_write_raw(line + "\n")
