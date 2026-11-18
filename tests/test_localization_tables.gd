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
		"PCH_CAMP_MORE",
		"PCH_CAMP_MORE_TEXT",
		"PCH_OBJ_HOLD",
		"PCH_Q_OFICIO_TITLE",
		"PCH_OFICIO_AGUA",
		"PCH_ACCOUNT_1",
		"PCH_FINAL_LLENA",
		"PCH_END5_NAME",
		"PCH_OBJ_MORNING",
		"PCH_OBJ_ENCARGOS",
		"PCH_MARK_MOTHER",
		"PCH_TRAIN_AIM",
		"PCH_TRAIN_MISS",
		"PCH_TRAIN_FAR",
		"PCH_NOTICE_TRAINING",
		"PCH_NOTICE_TASKS",
		"PCH_NOTICE_DOUBT",
		"PCH_NOTICE_MESSENGER",
		"PCH_NOTICE_ASSEMBLY",
	]
	for key: String in keys:
		if TranslationServer.translate(key) == key:
			printerr("Falta la clave de traducción ", key)
			return false
	return true
