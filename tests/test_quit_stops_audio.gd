extends RefCounted
## Comprueba el cierre ordenado de GameManager: el cierre de ventana no se
## acepta solo y todo el audio se detiene antes de salir, para evitar la fuga
## de reproducciones Ogg al cerrar en Godot 4.7.2.


func test_quit_stops_audio() -> bool:
	var tree: SceneTree = Engine.get_main_loop() as SceneTree
	if tree == null:
		return false
	var ok: bool = true
	# El autoload GameManager toma el control del cierre de ventana.
	ok = ok and not tree.auto_accept_quit
	ok = ok and GameManagerService.stop_audio_in(null) == 0

	var holder: Node3D = Node3D.new()
	tree.root.add_child(holder)
	var flat: AudioStreamPlayer = AudioStreamPlayer.new()
	flat.stream = AudioStreamGenerator.new()
	holder.add_child(flat)
	var nested: Node3D = Node3D.new()
	holder.add_child(nested)
	var spatial: AudioStreamPlayer3D = AudioStreamPlayer3D.new()
	spatial.stream = AudioStreamGenerator.new()
	nested.add_child(spatial)
	flat.play()
	spatial.play()
	var playing_before: int = int(flat.playing) + int(spatial.playing)

	ok = ok and playing_before == 2
	var stopped: int = GameManagerService.stop_audio_in(holder)
	ok = ok and stopped == playing_before
	ok = ok and not flat.playing
	ok = ok and not spatial.playing
	# El propio nodo raíz también se detiene si es un reproductor.
	flat.play()
	GameManagerService.stop_audio_in(flat)
	ok = ok and not flat.playing
	holder.free()
	return ok
