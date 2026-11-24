extends RefCounted
## Comprueba que el atuendo tolera una pieza nula sin leer su hueso.


func test_outfit_skips_null_part() -> bool:
	var model: Node3D = Node3D.new()
	var skeleton: Skeleton3D = Skeleton3D.new()
	skeleton.name = "Skeleton3D"
	model.add_child(skeleton)
	var look: CharacterLook = CharacterLook.new()
	look.parts.append(null)
	var ok: bool = look.parts.size() == 1
	CharacterOutfit.apply(model, look)
	# La pieza nula se descarta, pero la aplicación termina y deja su marca.
	var stored: Variant = model.get_meta(CharacterOutfit.PARTS_META, 0)
	ok = ok and stored is int and stored == 1
	model.free()
	return ok
