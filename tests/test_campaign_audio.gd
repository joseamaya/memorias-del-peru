extends RefCounted
## Comprueba los recursos de audio de los actos II y III y que los bucles se
## configuran al cargarlos. La integración en escena se revisa con
## `tests/inspect_audio.gd` bajo un driver real.

func test_campaign_audio_assets() -> bool:
	var paths: Array[String] = [
		CampaignAudio.AMBIENCE_PATH,
		CampaignAudio.MURMUR_PATH,
		CampaignAudio.WATER_PATH,
		CampaignAudio.FIRE_PATH,
		CampaignAudio.DRUM_PATH,
		CampaignAudio.WHOOSH_PATH,
		CampaignAudio.IMPACT_PATH,
		CampaignAudio.PORRA_PATH,
	]
	var ok: bool = true
	for path: String in paths:
		ok = ok and ResourceLoader.exists(path)
	var water: AudioStreamWAV = CampaignAudio.load_loop(CampaignAudio.WATER_PATH) as AudioStreamWAV
	ok = ok and water != null and water.loop_mode == AudioStreamWAV.LOOP_FORWARD
	var wind: AudioStreamOggVorbis = CampaignAudio.load_loop(CampaignAudio.AMBIENCE_PATH) as AudioStreamOggVorbis
	ok = ok and wind != null and wind.loop
	ok = ok and CampaignAudio.load_streams(CampaignAudio.DIRT_FOOTSTEPS).size() == 3
	ok = ok and CampaignAudio.load_streams(CampaignAudio.STONE_FOOTSTEPS).size() == 3
	return ok
