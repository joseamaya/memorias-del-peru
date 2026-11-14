extends SceneTree
## Verifica con un driver real que el paso y el Cusco crean sus nodos de audio.
## Uso: godot --path . --script res://tests/inspect_audio.gd

func _initialize() -> void:
	_go.call_deferred()


func _go() -> void:
	print("AUDIO_DRIVER=", AudioServer.get_driver_name())
	var paso: Node = (load("res://campaigns/01_pachacutec/scenes/world/paso.tscn") as PackedScene).instantiate()
	root.add_child(paso)
	await process_frame
	for node_name: String in ["WindAmbience", "StreamAmbience", "FireAmbience", "BattleDrum"]:
		print("PASO_", node_name, "=", paso.get_node_or_null(node_name) != null)
	paso.free()
	await process_frame
	var ciudad: Node = (load("res://campaigns/01_pachacutec/scenes/world/ciudad.tscn") as PackedScene).instantiate()
	root.add_child(ciudad)
	await process_frame
	for node_name: String in ["WindAmbience", "PlazaMurmur", "BattleDrum"]:
		print("CIUDAD_", node_name, "=", ciudad.get_node_or_null(node_name) != null)
	ciudad.free()
	var audio: Node = root.get_node_or_null("AudioManager")
	if audio != null:
		audio.call("stop_all")
	await create_timer(0.3).timeout
	print("AUDIO_INSPECT_OK")
	quit(0)
