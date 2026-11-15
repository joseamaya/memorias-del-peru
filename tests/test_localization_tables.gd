extends RefCounted
## Comprueba que las tablas de traducción de Core y campaña están cargadas.


func test_localization_tables() -> bool:
	var keys: Array[String] = [
		"INTERACT_DEFAULT",
		"PCH_QUERO_INTERACT",
		"PCH_TASK",
		"PCH_MSG_INTRO",
		"PCH_ASM4_NEWS",
		"PCH_CIUDAD_COST_ANCA",
		"PCH_PREP_AGUA",
		"PCH_ACCOUNT_1",
		"PCH_FINAL_LLENA",
		"PCH_END5_NAME",
	]
	for key: String in keys:
		if TranslationServer.translate(key) == key:
			printerr("Falta la clave de traducción ", key)
			return false
	return true
