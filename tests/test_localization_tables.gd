extends RefCounted
## Comprueba que las tablas de traducción de Core y campaña están cargadas.


func test_localization_tables() -> bool:
	return (
		TranslationServer.translate("INTERACT_DEFAULT") == "Interactuar"
		and TranslationServer.translate("PCH_QUERO_INTERACT") == "Beber chicha"
	)
