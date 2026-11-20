extends RefCounted
## Comprueba que las tablas de traducción de Core y campaña están cargadas y
## que no quedan claves huérfanas de la campaña retirada.


func test_localization_tables() -> bool:
	var keys: Array[String] = [
		"INTERACT_DEFAULT",
		"UI_GAME_TITLE",
		"UI_START",
		"UI_QUIT",
		"PCH_CAMPAIGN_SUBTITLE",
		"PCH_PLAY_CONTROLS",
		"PCH_REVIEW_CONTROLS",
	]
	for key: String in keys:
		if TranslationServer.translate(key) == key:
			printerr("Falta la clave de traducción ", key)
			return false
	return true


func test_localization_has_no_retired_campaign_text() -> bool:
	var retired: Array[String] = [
		"PCH_ASM4_NEWS",
		"PCH_CIUDAD_COST_ANCA",
		"PCH_END5_NAME",
		"PCH_QUERO_INTERACT",
	]
	for key: String in retired:
		if TranslationServer.translate(key) != key:
			printerr("Queda texto de la campaña retirada: ", key)
			return false
	return true
